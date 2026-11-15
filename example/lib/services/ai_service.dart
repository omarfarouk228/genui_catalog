import 'dart:async';
import 'dart:convert';

import 'package:a2ui_agent/a2ui_agent.dart';
import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:genui_catalog/genui_catalog.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;

/// Wires an A2UI [MessageProcessor] (the renderer), an `a2ui_agent`
/// request processor (prompt + response parsing) and Gemini together.
///
/// Usage:
/// ```dart
/// final service = AiService(apiKey: 'YOUR_KEY');
/// service.onSurfaceAdded = (id) => setState(() => _surfaceId = id);
/// await service.send('Show me a revenue dashboard');
/// // Then: A2uiSurface(surface: service.surface(id)!)
/// ```
/// Sends one turn to the model and streams its reply.
typedef TurnGenerator = Stream<String> Function(String turn);

class AiService {
  /// A service whose model is Gemini, called with [apiKey].
  AiService({required String apiKey})
    : this.withModel((systemPrompt) {
        final chat = genai.GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          systemInstruction: genai.Content.system(systemPrompt),
          generationConfig: genai.GenerationConfig(
            temperature: 0.4,
            maxOutputTokens: 8192,
          ),
        ).startChat();
        return (turn) => chat
            .sendMessageStream(genai.Content.text(turn))
            .map((response) => response.text ?? '');
      });

  /// A service whose model [createModel] creates from the system prompt.
  @visibleForTesting
  AiService.withModel(TurnGenerator Function(String systemPrompt) createModel) {
    _init();
    _generate = createModel(systemPrompt);
  }

  static final List<CatalogImplementation> _catalogs = [
    basicCatalog(),
    GenUICatalog.all,
  ];

  // ── A2UI ──────────────────────────────────────────────────────────────────

  /// The renderer: applies the model's messages and holds the surfaces.
  late final MessageProcessor<ComponentImplementation> processor;

  /// The agent side: the prompt snippet and the parser of Gemini's replies.
  late final A2uiRequestProcessor _agent;
  late final RendererState _state;

  // ── Model ─────────────────────────────────────────────────────────────────

  late final TurnGenerator _generate;

  /// The app instructions followed by the agent SDK's prompt snippet, which
  /// teaches the model the catalogs' components.
  String get systemPrompt => '$_appInstructions\n${_agent.promptSnippet}';

  // ── Callbacks ─────────────────────────────────────────────────────────────

  void Function(String surfaceId)? onSurfaceAdded;
  void Function(String surfaceId)? onSurfaceRemoved;
  ValueChanged<Object>? onError;

  bool _disposed = false;

  // ── Init ──────────────────────────────────────────────────────────────────

  void _init() {
    _agent =
        A2uiGenerator(
          catalogs: [for (final c in _catalogs) CatalogConfig(c)],
          inferenceFormatFactory: const DirectJsonFormatFactory(),
        ).createProcessor(
          A2uiRendererCapabilities.forCatalogIds([
            for (final c in _catalogs) c.id,
          ], version: A2uiProtocolVersion.v1_0),
        );
    _state = _agent.createState();

    processor = MessageProcessor<ComponentImplementation>(
      catalogs: _catalogs,
      defaultVersion: A2uiProtocolVersion.v1_0,
      // A half-streamed surface would fail the strict checks.
      validationConfig: ValidationConfig.relaxed,
      outboundListener: _sendOutbound,
      unifiedOutbound: true,
    );
    processor.model.onSurfaceCreated.subscribe((surface) {
      surface.onError.subscribe(
        (error) => debugPrint('AiService: ${error.code}: ${error.message}'),
      );
      onSurfaceAdded?.call(surface.id);
    });
    processor.model.onSurfaceDeleted.subscribe(
      (id) => onSurfaceRemoved?.call(id),
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  bool _isWaiting = false;
  bool get isWaiting => _isWaiting;

  /// The surface [surfaceId], once the model created it.
  SurfaceModel<ComponentImplementation>? surface(String surfaceId) =>
      processor.model.getSurface(surfaceId);

  /// Sends [userText] to Gemini and applies the UI it streams back.
  Future<void> send(String userText) async {
    if (_isWaiting || userText.trim().isEmpty) return;
    await _runTurn(userText.trim());
  }

  // ── Turns ─────────────────────────────────────────────────────────────────

  Future<void> _runTurn(String turn) async {
    _isWaiting = true;
    final ResponseStream stream = _agent.openStream(state: _state);
    try {
      await for (final chunk in _generate(turn)) {
        if (_disposed) return;
        if (chunk.isNotEmpty) _deliver(stream.feed(chunk));
      }
      _deliver(stream.close());
    } on A2uiError catch (e) {
      // Apply what was valid before the failure, then report it.
      _deliver(e.partialResults.whereType<ResponsePart>().toList());
      debugPrint('AiService: rejected reply: $e');
      onError?.call(e);
    } catch (e, st) {
      debugPrint('AiService.send error: $e\n$st');
      onError?.call(e);
    } finally {
      _isWaiting = false;
    }
  }

  void _deliver(List<ResponsePart> parts) {
    for (final part in parts) {
      if (part case A2uiPart(:final a2ui)) {
        for (final message in a2ui) {
          processor.processMessages(AgentToRendererMessagePayload.of(message));
        }
      } else if (part case TextPart(:final text)) {
        if (text.trim().isNotEmpty) debugPrint('AiService: model says: $text');
      }
    }
  }

  /// Sends a user action on a surface back to Gemini as the next turn, with
  /// the data model of surfaces created with `sendDataModel`.
  void _sendOutbound(RendererToAgentMessage message) {
    if (_disposed || message is ErrorMessage) return;
    if (message is ActionMessage) {
      debugPrint(
        'AiService: action ${message.action.name} '
        '${jsonEncode(message.action.context)}',
      );
    }
    final dataModel = processor.getRendererDataModel();
    final turn = jsonEncode({
      'a2ui': RendererToAgentMessagePayload([message]).toJson(),
      if (dataModel != null) 'metadata': {'a2uiRendererDataModel': dataModel},
    });
    unawaited(_runTurn(turn));
  }

  void dispose() {
    _disposed = true;
    processor.dispose();
  }
}

// ---------------------------------------------------------------------------
// App instructions (the catalogs' components come from the agent SDK's
// prompt snippet)
// ---------------------------------------------------------------------------

const _appInstructions = '''
You are a UI generation assistant demonstrating the genui_catalog Flutter
package. Answer each request with one A2UI surface that showcases the
GenUI Catalog components best matching it, with realistic sample data.

- Give each new surface a new surfaceId. Use the GenUI Catalog components
  (KpiCard, ChartCard, ActionForm, RatingInput, ...) and its Column/Row for
  layout; use the basic catalog only for plain Text or Button.
- Write numbers shown as text as strings: "value": "\$12,450", not 12450.
- On a surface with inputs, set "sendDataModel": true and bind input values
  to data model paths.
- When the user acts on a surface, the next user turn is JSON whose "a2ui"
  holds the renderer's v1.0 messages: an action with its name and context.
  Answer it by updating that surface, or with a short new surface.
''';
