import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:genui_catalog/genui_catalog.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;

/// Wires [SurfaceController] + [A2uiTransportAdapter] + Gemini together.
///
/// Usage:
/// ```dart
/// final service = AiService(apiKey: 'YOUR_KEY');
/// service.onSurfaceAdded = (id) => setState(() => _surfaceId = id);
/// await service.send('Show me a revenue dashboard');
/// // Then: Surface(surfaceContext: service.controller.surfaceContext(id))
/// ```
class AiService {
  AiService({required String apiKey}) {
    _init(apiKey);
  }

  // ── genui ─────────────────────────────────────────────────────────────────

  late final SurfaceController controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;

  // ── Gemini ────────────────────────────────────────────────────────────────

  late final genai.GenerativeModel _model;
  genai.ChatSession? _chat;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  void Function(String surfaceId)? onSurfaceAdded;
  void Function(String surfaceId)? onSurfaceRemoved;
  ValueChanged<Object>? onError;

  StreamSubscription<ChatMessage>? _controllerSubmitSubscription;

  // ── Init ──────────────────────────────────────────────────────────────────

  void _init(String apiKey) {
    controller = SurfaceController(
      catalogs: [BasicCatalogItems.asCatalog(), GenUICatalog.all],
    );

    _transport = A2uiTransportAdapter(onSend: _handleTransportSend);
    _transport.incomingMessages.listen((message) {
      try {
        controller.handleMessage(message);
      } catch (e, st) {
        debugPrint('SurfaceController.handleMessage error: $e\n$st');
        onError?.call(e);
      }
    });

    _conversation = Conversation(controller: controller, transport: _transport);

    _controllerSubmitSubscription = controller.onSubmit.listen((message) {
      // Log UI interaction events (button clicks, field submissions) for debugging.
      debugPrint('AiService: submit event from UI action -> $message');
    });

    _conversation.events.listen((event) {
      debugPrint('AiService: Conversation event: $event');
      if (event is ConversationSurfaceAdded) {
        debugPrint('AiService: Surface added: ${event.surfaceId}');
        onSurfaceAdded?.call(event.surfaceId);
      } else if (event is ConversationSurfaceRemoved) {
        debugPrint('AiService: Surface removed: ${event.surfaceId}');
        onSurfaceRemoved?.call(event.surfaceId);
      }
    });

    // Build the system prompt — includes every component schema from the
    // catalog so Gemini knows exactly what components exist.
    final promptBuilder = PromptBuilder.chat(
      catalog: GenUICatalog.all,
      systemPromptFragments: [_systemInstructions],
    );

    _model = genai.GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: genai.Content.system(
        promptBuilder.systemPrompt().map((fragment) => fragment).join('\n'),
      ),
      generationConfig: genai.GenerationConfig(
        temperature: 0.4,
        maxOutputTokens: 4096,
      ),
    );

    _chat = _model.startChat();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  bool _isWaiting = false;
  bool get isWaiting => _isWaiting;

  /// Sends [userText] to Gemini and streams the response through the
  /// genui transport pipeline.
  Future<void> send(String userText) async {
    debugPrint('AiService: Sending request: $userText');
    _responseBuffer.clear(); // Clear buffer for new request
    if (_isWaiting || userText.trim().isEmpty) return;
    _isWaiting = true;

    try {
      await _conversation.sendRequest(
        ChatMessage(
          role: ChatMessageRole.user,
          parts: [TextPart(userText.trim())],
        ),
      );
      debugPrint('AiService: Request sent successfully');
    } catch (e, st) {
      debugPrint('AiService.send error: $e\n$st');
      onError?.call(e);
    } finally {
      _isWaiting = false;
    }
  }

  Future<void> _handleTransportSend(ChatMessage message) async {
    try {
      final parts = <genai.Part>[];
      for (final part in message.parts) {
        if (part is TextPart) {
          parts.add(genai.TextPart(part.text));
        } else if (part is DataPart) {
          if (part.mimeType == UiPartConstants.interactionMimeType) {
            try {
              final uiInteraction = UiInteractionPart.fromDataPart(part);
              final interactionText = _interactionToPrompt(
                uiInteraction.interaction,
              );
              parts.add(genai.TextPart(interactionText));
            } catch (e) {
              debugPrint('AiService: Failed to parse UiInteractionPart: $e');
            }
          } else if (part.mimeType == UiPartConstants.uiMimeType) {
            // UI definition parts should not be forwarded to the LLM.
            continue;
          } else {
            parts.add(genai.DataPart(part.mimeType, part.bytes));
          }
        }
      }

      if (parts.isEmpty) {
        debugPrint('AiService: No model-compatible parts to send; skipping');
        return;
      }

      final content = genai.Content(message.role.name, parts);
      final stream = _chat!.sendMessageStream(content);

      // Reset buffer for new request
      _responseBuffer.clear();

      await for (final response in stream) {
        _processModelResponse(response);
      }

      // Process any remaining content in buffer after stream ends
      if (_responseBuffer.isNotEmpty) {
        debugPrint('AiService: Processing final buffer content');
        _processFinalBuffer();
      }
    } catch (e, st) {
      debugPrint('AiService._handleTransportSend error: $e\n$st');
      onError?.call(e);
    }
  }

  String _interactionToPrompt(String interactionJson) {
    try {
      final dynamic payload = json.decode(interactionJson);
      if (payload is Map<String, dynamic> && payload['action'] != null) {
        final action = payload['action'];
        // Provide a simple, readable action message for the model.
        return 'User interaction event: ${json.encode(action)}';
      }
    } catch (_) {
      // Fall back to raw interaction string.
    }
    return 'User interaction event: $interactionJson';
  }

  void _processModelResponse(genai.GenerateContentResponse response) {
    // Only process the parts, not response.text to avoid duplication
    for (final candidate in response.candidates) {
      for (final part in candidate.content.parts) {
        if (part is genai.DataPart) {
          try {
            final decoded = utf8.decode(part.bytes);
            if (decoded.isNotEmpty) {
              debugPrint('AiService: Received data chunk: $decoded');
              _accumulateResponse(decoded);
            }
          } catch (_) {
            // Non UTF-8 bytes are not processed.
          }
        } else if (part is genai.TextPart) {
          if (part.text.isNotEmpty) {
            debugPrint('AiService: Received text part: ${part.text}');
            _accumulateResponse(part.text);
          }
        }
      }
    }
    // Don't parse here - wait for stream to complete
  }

  final StringBuffer _responseBuffer = StringBuffer();

  void _accumulateResponse(String text) {
    // Simply accumulate all text - parsing will happen after stream completes
    _responseBuffer.write(text);
  }

  void _processFinalBuffer() {
    final content = _responseBuffer.toString();
    debugPrint(
      'AiService: Final buffer content (${content.length} chars): $content',
    );

    // Try multiple strategies to extract JSON objects
    final jsonObjects = <String>[];

    // Strategy 1: Clean fragmented content first, then extract by version patterns
    final cleanedContent = _cleanFragmentedContent(content);
    jsonObjects.addAll(_extractJsonByVersionPattern(cleanedContent));

    // Strategy 2: If no objects found, try advanced brace counting on cleaned content
    if (jsonObjects.isEmpty) {
      jsonObjects.addAll(_extractAllCompleteJsonObjects(cleanedContent));
    }

    // Strategy 3: Fallback to original content with other methods
    if (jsonObjects.isEmpty) {
      jsonObjects.addAll(_extractJsonByVersionPattern(content));
      if (jsonObjects.isEmpty) {
        jsonObjects.addAll(_extractAllCompleteJsonObjects(content));
        if (jsonObjects.isEmpty) {
          jsonObjects.addAll(_extractJsonObjectsFromContent(content));
          if (jsonObjects.isEmpty) {
            jsonObjects.addAll(_extractJsonBySplitting(content));
            if (jsonObjects.isEmpty) {
              jsonObjects.addAll(_repairAndExtractJson(content));
            }
          }
        }
      }
    }

    // Process each extracted JSON object
    for (final jsonStr in jsonObjects) {
      try {
        final decoded = json.decode(jsonStr);
        if (decoded is Map && decoded.containsKey('version')) {
          debugPrint('AiService: Valid A2UI JSON found: $jsonStr');
          _transport.addChunk(jsonStr);
        } else {
          debugPrint('AiService: Skipping non-A2UI JSON: $jsonStr');
        }
      } catch (e) {
        debugPrint('AiService: JSON decode error: $e for: $jsonStr');
        // Try to repair this specific JSON object
        final repaired = _repairSingleJsonObject(jsonStr);
        if (repaired != null) {
          try {
            final decoded = json.decode(repaired);
            if (decoded is Map && decoded.containsKey('version')) {
              debugPrint('AiService: Repaired and valid A2UI JSON: $repaired');
              _transport.addChunk(repaired);
            }
          } catch (e2) {
            debugPrint('AiService: Even repaired JSON failed: $e2');
          }
        }
      }
    }

    // Clear buffer after processing
    _responseBuffer.clear();
  }

  String _cleanFragmentedContent(String content) {
    // Remove excessive whitespace and normalize
    String cleaned = content.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Look for patterns where JSON objects are duplicated or overlapping
    // Pattern: {"version": "v0.9", ...}{"version": "v0.9", ...
    final duplicatePattern = RegExp(
      r'\{"version":\s*"[^"]*"(?:[^{}]|{[^{}]*})*\}\{"version":\s*"[^"]*"',
    );
    cleaned = cleaned.replaceAllMapped(duplicatePattern, (match) {
      final fullMatch = match.group(0)!;
      // Try to extract the second complete object if the first is incomplete
      final braceIndex = fullMatch.lastIndexOf('}{');
      if (braceIndex != -1) {
        final secondPart = fullMatch.substring(braceIndex + 1);
        if (secondPart.contains('"version"') &&
            _isValidJsonStructure(secondPart)) {
          return secondPart;
        }
      }
      return fullMatch;
    });

    // Remove malformed fragments that start with incomplete JSON
    // Pattern: some text{"version": but missing closing
    final fragments = cleaned.split('{"version":');
    if (fragments.length > 1) {
      final result = StringBuffer();
      // Always include the first fragment (might be empty)
      result.write(fragments[0]);

      for (int i = 1; i < fragments.length; i++) {
        final fragment = fragments[i];
        // Check if this fragment looks like it could be part of a complete object
        if (fragment.contains('"catalogId"') ||
            fragment.contains('"surfaceId"')) {
          // Try to reconstruct: {"version": + fragment
          final candidate = '{"version":$fragment';
          if (_isValidJsonStructure(candidate)) {
            result.write(candidate);
          } else {
            // Try to find a complete object within this fragment
            final completeObject = _extractCompleteObjectFromFragment(fragment);
            if (completeObject != null) {
              result.write(completeObject);
            }
          }
        }
      }
      cleaned = result.toString();
    }

    return cleaned;
  }

  List<String> _extractJsonByVersionPattern(String content) {
    final objects = <String>[];
    final versionPattern = RegExp(r'\{"version":\s*"[^"]*"');
    final matches = versionPattern.allMatches(content);

    for (final match in matches) {
      final startIndex = match.start;
      // Try to extract a complete JSON object starting from this version
      final jsonObject = _extractCompleteJsonFromPosition(content, startIndex);
      if (jsonObject != null) {
        // Validate it's a proper A2UI object
        try {
          final decoded = json.decode(jsonObject);
          if (decoded is Map &&
              decoded.containsKey('version') &&
              (decoded.containsKey('createSurface') ||
                  decoded.containsKey('updateComponents'))) {
            objects.add(jsonObject);
          }
        } catch (_) {
          // Skip invalid JSON
        }
      }
    }

    return objects;
  }

  String? _extractCompleteObjectFromFragment(String fragment) {
    // Try to find complete JSON objects within a fragment
    int braceCount = 0;
    bool inString = false;
    bool escaped = false;
    int startIndex = -1;

    for (int i = 0; i < fragment.length; i++) {
      final char = fragment[i];

      if (escaped) {
        escaped = false;
      } else if (char == '\\') {
        escaped = true;
      } else if (char == '"') {
        inString = !inString;
      } else if (!inString) {
        if (char == '{') {
          if (braceCount == 0) startIndex = i;
          braceCount++;
        } else if (char == '}') {
          braceCount--;
          if (braceCount == 0 && startIndex != -1) {
            final candidate = fragment.substring(startIndex, i + 1);
            if (_isValidJsonStructure('{"version":$candidate')) {
              return '{"version":$candidate';
            }
          }
        }
      }
    }

    return null;
  }

  String? _extractCompleteJsonFromPosition(String content, int startIndex) {
    int braceCount = 0;
    bool inString = false;
    bool escaped = false;
    int objectStart = -1;

    for (int i = startIndex; i < content.length; i++) {
      final char = content[i];

      if (escaped) {
        escaped = false;
      } else if (char == '\\') {
        escaped = true;
      } else if (char == '"') {
        inString = !inString;
      } else if (!inString) {
        if (char == '{') {
          if (braceCount == 0) objectStart = i;
          braceCount++;
        } else if (char == '}') {
          braceCount--;
          if (braceCount == 0 && objectStart != -1) {
            final candidate = content.substring(objectStart, i + 1);
            // Additional validation: ensure it ends with } and has balanced braces
            if (_isValidJsonStructure(candidate)) {
              return candidate;
            }
          }
        }
      }
    }

    return null;
  }

  List<String> _extractAllCompleteJsonObjects(String content) {
    final objects = <String>[];
    int i = 0;

    while (i < content.length) {
      // Skip whitespace and non-JSON content
      while (i < content.length && content[i] != '{') {
        i++;
      }

      if (i >= content.length) break;

      // Check if this looks like the start of a version object
      if (i + 10 < content.length &&
          content.substring(i, i + 10).contains('"version"')) {
        // Try to extract a complete JSON object starting from here
        final jsonObject = _extractSingleCompleteJsonObject(content, i);
        if (jsonObject != null) {
          objects.add(jsonObject);
          i += jsonObject.length;
          continue;
        }
      }

      i++;
    }

    return objects;
  }

  String? _extractSingleCompleteJsonObject(String content, int startIndex) {
    int braceCount = 0;
    bool inString = false;
    bool escaped = false;
    int objectStart = -1;

    for (int i = startIndex; i < content.length; i++) {
      final char = content[i];

      if (escaped) {
        escaped = false;
      } else if (char == '\\') {
        escaped = true;
      } else if (char == '"') {
        inString = !inString;
      } else if (!inString) {
        if (char == '{') {
          if (braceCount == 0) objectStart = i;
          braceCount++;
        } else if (char == '}') {
          braceCount--;
          if (braceCount == 0 && objectStart != -1) {
            return content.substring(objectStart, i + 1);
          }
        }
      }
    }

    return null;
  }

  bool _isValidJsonStructure(String jsonStr) {
    try {
      json.decode(jsonStr);
      return true;
    } catch (_) {
      return false;
    }
  }

  List<String> _extractJsonBySplitting(String content) {
    final objects = <String>[];
    final parts = content.split('}{');

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();

      // Add back the braces that were removed by split
      if (i == 0 && !part.startsWith('{')) {
        part = '{$part';
      }
      if (i == parts.length - 1 && !part.endsWith('}')) {
        part = '$part}';
      } else if (i < parts.length - 1) {
        part = '$part}';
        if (!parts[i + 1].startsWith('{')) {
          parts[i + 1] = '{${parts[i + 1]}';
        }
      }

      if (part.isNotEmpty) {
        objects.add(part);
      }
    }

    return objects;
  }

  List<String> _repairAndExtractJson(String content) {
    final objects = <String>[];

    // Look for patterns like {"version": "v0.9", ...} followed by another {"version": "v0.9", ...}
    final versionPattern = RegExp(
      r'(\{"version":\s*"[^"]*",.*?\})(?=\{"version":\s*"[^"]*")',
      dotAll: true,
    );
    final matches = versionPattern.allMatches(content);

    for (final match in matches) {
      final jsonStr = match.group(1);
      if (jsonStr != null) {
        objects.add(jsonStr);
      }
    }

    // If no matches, try to extract the entire content as one object
    if (objects.isEmpty &&
        content.trim().startsWith('{') &&
        content.trim().endsWith('}')) {
      objects.add(content.trim());
    }

    return objects;
  }

  String? _repairSingleJsonObject(String jsonStr) {
    // Try to fix common JSON issues
    String repaired = jsonStr.trim();

    // Fix missing quotes around property names
    repaired = repaired.replaceAllMapped(
      RegExp(r'([{,]\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*:'),
      (match) => '${match.group(1)}"${match.group(2)}":',
    );

    // Fix trailing commas before closing braces/brackets
    repaired = repaired.replaceAllMapped(
      RegExp(r',(\s*[}\]])'),
      (match) => match.group(1)!,
    );

    // Try to balance braces if needed
    int openBraces = '{'.allMatches(repaired).length;
    int closeBraces = '}'.allMatches(repaired).length;

    if (openBraces > closeBraces) {
      repaired += '}' * (openBraces - closeBraces);
    } else if (closeBraces > openBraces) {
      repaired = '{' * (closeBraces - openBraces) + repaired;
    }

    return repaired;
  }

  List<String> _extractJsonObjectsFromContent(String content) {
    final objects = <String>[];
    int i = 0;

    while (i < content.length) {
      // Skip whitespace and find the start of a JSON object
      while (i < content.length && content[i] != '{') {
        i++;
      }

      if (i >= content.length) break;

      // Found potential start of JSON object
      final startIndex = i;
      int braceCount = 0;
      bool inString = false;
      bool escaped = false;

      // Parse through the content to find complete JSON objects
      while (i < content.length) {
        final char = content[i];

        if (escaped) {
          escaped = false;
        } else if (char == '\\') {
          escaped = true;
        } else if (char == '"') {
          inString = !inString;
        } else if (!inString) {
          if (char == '{') {
            braceCount++;
          } else if (char == '}') {
            braceCount--;
            // Check if we've found a complete object
            if (braceCount == 0) {
              final jsonCandidate = content.substring(startIndex, i + 1);
              objects.add(jsonCandidate);
              i++; // Move past the closing brace
              break;
            }
          }
        }

        i++;
      }
    }

    return objects;
  }

  void dispose() {
    _controllerSubmitSubscription?.cancel();
    _conversation.dispose();
    _transport.dispose();
    controller.dispose();
  }
}

// ---------------------------------------------------------------------------
// System instructions
// ---------------------------------------------------------------------------

const _systemInstructions = '''
You are a UI generation assistant demonstrating the genui_catalog Flutter package.
Generate Flutter UIs using the genui v0.9 protocol with the following components:

KpiCard       → single KPI metric with trend indicator (up/down/neutral)
StatRow       → 2–4 side-by-side stat cards
DataTable     → tabular data with columns and rows
ChartCard     → line / bar / pie chart (chartType required)
TimelineCard  → vertical sequence of events with status (done/active/pending)
StatusBadge   → colored status chip (success/warning/error/info/neutral)
StepperCard   → multi-step process navigator with navigation buttons
ActionForm    → dynamic form with typed fields and a submit button
SearchBar     → debounced search input
RatingInput   → star rating picker
ProfileCard   → person card with avatar, details, and action buttons
MediaCard     → content card with image, tags, and action buttons
SwitchGroup   → group of toggle switches with labels and subtitles
SelectInput   → dropdown selection input with options
CheckboxGroup → group of checkboxes with labels

CRITICAL JSON OUTPUT REQUIREMENTS:
- Output EXACTLY TWO separate JSON objects, one per line
- NEVER split a single JSON object across multiple lines or responses
- Each JSON object must be complete and parseable on its own
- NEVER use markdown code blocks (```json or ```)
- NEVER add any text before or after the JSON
- Use "version": "v0.9" and "catalogId": "genui_catalog"
- All JSON field names must be camelCase
- All payloads must be valid JSON

REQUIRED OUTPUT FORMAT:
First line: {"version": "v0.9", "createSurface": {...}}
Second line: {"version": "v0.9", "updateComponents": {...}}

Example (output these exact two lines):
{"version": "v0.9", "createSurface": {"surfaceId": "example", "catalogId": "genui_catalog", "sendDataModel": true}}
{"version": "v0.9", "updateComponents": {"surfaceId": "example", "components": [{"id": "root", "component": "Column", "children": ["card1"]}, {"id": "card1", "component": "KpiCard", "title": "Revenue", "value": "\$12,450", "trend": "up"}]}}

Rules:
- Always emit createSurface first, then updateComponents on separate lines
- In createSurface, set "version": "v0.9" and "catalogId": "genui_catalog"
- All `updateComponents.components` entries must have a non-empty `id`
- The root component should have `id: "root"`
- If you need to stack components vertically/horizontally, use `Column` or `Row` with `children` ids
- Use realistic, domain-appropriate sample data
- All payloads must be valid JSON or valid GenUI protocol values (quoted strings for text, no unquoted commas in numbers, no raw currency/percent suffixes unless as string values)
- Prefer safe values: e.g. "value": "12450" or "85,320" as string, not raw 12,450 or 85,320, and avoid unquoted percent signs like 4.7%
- Choose components that best match the user's request
''';
