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

    // Extract all complete JSON objects using brace counting on the raw buffer.
    // This reliably handles the case where the LLM outputs multiple JSON objects
    // separated by whitespace/newlines.
    final jsonObjects = _extractJsonObjectsFromContent(content);

    for (final jsonStr in jsonObjects) {
      try {
        final decoded = json.decode(jsonStr);
        if (decoded is Map &&
            decoded.containsKey('version') &&
            (decoded.containsKey('createSurface') ||
                decoded.containsKey('updateComponents'))) {
          debugPrint('AiService: Valid A2UI JSON found: $jsonStr');
          _transport.addChunk(jsonStr);
        }
      } catch (e) {
        debugPrint('AiService: JSON decode error: $e for: $jsonStr');
      }
    }

    _responseBuffer.clear();
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

      // If we exhausted the content with unclosed braces, the LLM truncated
      // the JSON (missing closing `}` chars). Repair by appending them.
      if (braceCount > 0) {
        final truncated = content.substring(startIndex);
        final repaired = truncated + ('}' * braceCount);
        try {
          json.decode(repaired);
          objects.add(repaired);
        } catch (_) {
          // Cannot repair — skip
        }
        break;
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
