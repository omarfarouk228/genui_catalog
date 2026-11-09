import 'dart:async';
import 'dart:convert';

import 'package:a2ui_agent/a2ui_agent.dart';
import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/v0_9/basic_catalog.dart' as v0_9;
import 'package:flutter/foundation.dart';
import 'package:genui_catalog/genui_catalog.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;
import 'package:url_launcher/url_launcher.dart';

/// Wires [MessageProcessor] + the `a2ui_agent` prompt and parser + Gemini
/// together.
///
/// Usage:
/// ```dart
/// final service = AiService(apiKey: 'YOUR_KEY');
/// service.onSurfaceAdded = (id) => setState(() => _surfaceId = id);
/// await service.send('Show me a revenue dashboard');
/// // Then: A2uiSurface(surface: service.processor.model.getSurface(id)!)
/// ```
class AiService {
  AiService({required String apiKey}) {
    _init(apiKey);
  }

  // ── A2UI ──────────────────────────────────────────────────────────────────

  late final MessageProcessor<ComponentImplementation> processor;
  late final A2uiRequestProcessor _agent;
  final List<Subscription> _subscriptions = [];

  static final String _version = A2uiProtocolVersion.v0_9.jsonValue;

  // ── Gemini ────────────────────────────────────────────────────────────────

  late final genai.GenerativeModel _model;
  genai.ChatSession? _chat;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  void Function(String surfaceId)? onSurfaceAdded;
  void Function(String surfaceId)? onSurfaceRemoved;
  ValueChanged<Object>? onError;

  // ── Init ──────────────────────────────────────────────────────────────────

  void _init(String apiKey) {
    processor = MessageProcessor(
      // The basic catalog opens URLs with url_launcher, as genui's did. The
      // model can open a URL without the user acting; the demo trusts it to.
      catalogs: [
        v0_9.basicCatalog(openUrl: launchUrl),
        GenUICatalog.all,
      ],
      // A surface streams in over several messages, which the strict checks
      // would reject.
      validationConfig: ValidationConfig.relaxed,
      reportErrorsOnly: true,
    );

    _subscriptions.addAll([
      processor.model.onSurfaceCreated.subscribe((surface) {
        debugPrint('AiService: Surface added: ${surface.id}');
        onSurfaceAdded?.call(surface.id);
      }),
      processor.model.onSurfaceDeleted.subscribe((surfaceId) {
        debugPrint('AiService: Surface removed: $surfaceId');
        onSurfaceRemoved?.call(surfaceId);
      }),
      // Send UI interaction events (button clicks, field submissions) and the
      // errors the renderer meets to Gemini, as genui's Conversation did.
      processor.model.onAction.subscribe((action) {
        final message = ActionMessage(version: _version, action: action);
        debugPrint('AiService: UI action -> ${message.toJson()}');
        unawaited(_sendToModel(_interactionToPrompt(message.toJson())));
      }),
      processor.model.onError.subscribe((error) {
        final message = ErrorMessage(version: _version, error: error);
        debugPrint('AiService: Renderer error -> ${message.toJson()}');
        unawaited(_sendToModel(_interactionToPrompt(message.toJson())));
      }),
    ]);

    // Build the system prompt — includes every component schema from the
    // catalog so Gemini knows exactly what components exist. Like genui's
    // chat prompt, it lets each reply create surfaces but not change the
    // surfaces of earlier replies.
    _agent =
        A2uiGenerator(
          catalogs: [CatalogConfig(GenUICatalog.all)],
          inferenceFormatFactory: const DirectJsonFormatFactory(
            allowedMessages: ['createSurface', 'updateComponents'],
          ),
        ).createProcessor(
          A2uiRendererCapabilities.forCatalogIds([GenUICatalog.catalogId]),
        );

    _model = genai.GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: genai.Content.system(
        '$_systemInstructions\n${_agent.promptSnippet}',
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

  /// Sends [userText] to Gemini and renders the A2UI messages of its reply.
  Future<void> send(String userText) async {
    debugPrint('AiService: Sending request: $userText');
    if (_isWaiting || userText.trim().isEmpty) return;
    _isWaiting = true;

    try {
      await _sendToModel(userText.trim());
      debugPrint('AiService: Request sent successfully');
    } catch (e, st) {
      debugPrint('AiService.send error: $e\n$st');
      onError?.call(e);
    } finally {
      _isWaiting = false;
    }
  }

  /// Sends [text] to Gemini as a user turn and processes its streamed reply.
  Future<void> _sendToModel(String text) async {
    try {
      final stream = _chat!.sendMessageStream(genai.Content.text(text));

      // Each reply is read on its own, so it can only create new surfaces.
      final ResponseStream reply = _agent.openStream();
      await for (final response in stream) {
        _processParts(reply.feed(_responseText(response)));
      }
      _processParts(reply.close());
    } on A2uiError catch (e) {
      // The reply could not be read or holds a message the catalog rejects.
      // Render the messages read before that, and show the error.
      _processParts(e.partialResults);
      debugPrint('AiService: Reply rejected: $e');
      onError?.call(e);
    } catch (e, st) {
      debugPrint('AiService._sendToModel error: $e\n$st');
      onError?.call(e);
    }
  }

  String _interactionToPrompt(Map<String, dynamic> payload) {
    final action = payload['action'];
    if (action != null) {
      // Provide a simple, readable action message for the model.
      return 'User interaction event: ${json.encode(action)}';
    }
    return 'User interaction event: ${json.encode(payload)}';
  }

  String _responseText(genai.GenerateContentResponse response) {
    // Only read the parts, not response.text to avoid duplication
    final text = StringBuffer();
    for (final candidate in response.candidates) {
      for (final part in candidate.content.parts) {
        if (part is genai.DataPart) {
          try {
            final decoded = utf8.decode(part.bytes);
            if (decoded.isNotEmpty) {
              debugPrint('AiService: Received data chunk: $decoded');
              text.write(decoded);
            }
          } catch (_) {
            // Non UTF-8 bytes are not processed.
          }
        } else if (part is genai.TextPart) {
          if (part.text.isNotEmpty) {
            debugPrint('AiService: Received text part: ${part.text}');
            text.write(part.text);
          }
        }
      }
    }
    return text.toString();
  }

  void _processParts(List<ResponsePart> parts) {
    for (final part in parts) {
      switch (part) {
        case TextPart(:final text):
          debugPrint('AiService: Text outside A2UI JSON: $text');
        case A2uiPart(:final a2ui):
          processor.processMessages(AgentToRendererMessagePayload(a2ui));
      }
    }
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.unsubscribe();
    }
    processor.dispose();
  }
}

// ---------------------------------------------------------------------------
// System instructions
// ---------------------------------------------------------------------------

const _systemInstructions = '''
You are a UI generation assistant demonstrating the genui_catalog Flutter package.
Generate Flutter UIs using the A2UI v0.9 protocol with the following components:

KpiCard       → single KPI metric with trend indicator (up/down/neutral)
StatRow       → 2–4 side-by-side stat cards
DataTable     → tabular data with columns and rows
ChartCard     → line / bar / pie chart (chartType required)
TimelineCard  → vertical sequence of events with status (done/active/pending)
StatusBadge   → colored status chip (success/warning/error/info/neutral)
StepperCard   → multi-step process navigator with navigation buttons (previousLabel/nextLabel)
ActionForm    → dynamic form with typed fields and a submit button
SearchBar     → debounced search input
RatingInput   → star rating picker; rating_submitted carries {rating, maxStars}
ProfileCard   → person card with avatar, details, and action buttons
MediaCard     → content card with image, tags, and action buttons
SwitchGroup   → group of toggle switches with labels and subtitles (submitLabel = one Save button)
SelectInput   → dropdown selection input with options
CheckboxGroup → group of checkboxes with labels (submitLabel = one submit button)

CRITICAL JSON OUTPUT REQUIREMENTS:
- Output EXACTLY ONE <a2ui-json> block holding a JSON array of TWO messages, one per line
- NEVER split a single JSON object across multiple lines or responses
- Each JSON object must be complete and parseable on its own
- NEVER use markdown code blocks (```json or ```)
- NEVER add any text before or after the block
- Use "version": "v0.9" and "catalogId": "genui_catalog"
- All JSON field names must be camelCase
- All payloads must be valid JSON

REQUIRED OUTPUT FORMAT:
<a2ui-json>
[{"version": "v0.9", "createSurface": {...}},
{"version": "v0.9", "updateComponents": {...}}]
</a2ui-json>

Example (output exactly this shape):
<a2ui-json>
[{"version": "v0.9", "createSurface": {"surfaceId": "example", "catalogId": "genui_catalog", "sendDataModel": true}},
{"version": "v0.9", "updateComponents": {"surfaceId": "example", "components": [{"id": "root", "component": "Column", "children": ["card1"]}, {"id": "card1", "component": "KpiCard", "title": "Revenue", "value": "\$12,450", "trend": "up"}]}}]
</a2ui-json>

Rules:
- Always emit createSurface first, then updateComponents on separate lines
- In createSurface, set "version": "v0.9" and "catalogId": "genui_catalog"
- Never update or modify a surface created in a previous turn. If the UI needs to change, create a new surface with a new unique surfaceId
- All `updateComponents.components` entries must have a non-empty `id`
- The root component should have `id: "root"`
- If you need to stack components vertically/horizontally, use `Column` or `Row` with `children` ids
- Use realistic, domain-appropriate sample data
- All payloads must be valid JSON or valid A2UI protocol values (quoted strings for text, no unquoted commas in numbers, no raw currency/percent suffixes unless as string values)
- Prefer safe values: e.g. "value": "12450" or "85,320" as string, not raw 12,450 or 85,320, and avoid unquoted percent signs like 4.7%
- Choose components that best match the user's request
''';
