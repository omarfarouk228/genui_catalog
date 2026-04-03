import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:genui_catalog/genui_catalog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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

  late final GenerativeModel _model;
  ChatSession? _chat;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  void Function(String surfaceId)? onSurfaceAdded;
  void Function(String surfaceId)? onSurfaceRemoved;
  ValueChanged<Object>? onError;

  // ── Init ──────────────────────────────────────────────────────────────────

  void _init(String apiKey) {
    controller = SurfaceController(
      catalogs: [
        CoreCatalogItems.asCatalog(),
        GenUICatalog.all,
      ],
    );

    _transport = A2uiTransportAdapter();
    _transport.messageStream.listen(controller.handleMessage);

    _conversation = Conversation(
      surfaceController: controller,
      transportAdapter: _transport,
      onSurfaceAdded: (update) => onSurfaceAdded?.call(update.surfaceId),
      onSurfaceDeleted: (update) => onSurfaceRemoved?.call(update.surfaceId),
    );

    // Build the system prompt — includes every component schema from the
    // catalog so Gemini knows exactly what components exist.
    final promptBuilder = PromptBuilder.chat(
      catalog: GenUICatalog.all,
      instructions: _systemInstructions,
    );

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(promptBuilder.systemPrompt),
      generationConfig: GenerationConfig(
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
    if (_isWaiting || userText.trim().isEmpty) return;
    _isWaiting = true;

    try {
      _conversation.sendMessage(userText.trim());

      final stream = _chat!.sendMessageStream(Content.text(userText.trim()));
      await for (final response in stream) {
        final text = response.text;
        if (text != null && text.isNotEmpty) {
          _transport.addChunk(text);
        }
      }
    } catch (e, st) {
      debugPrint('AiService.send error: $e\n$st');
      onError?.call(e);
    } finally {
      _isWaiting = false;
    }
  }

  void dispose() {
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

Rules:
- Always emit createSurface first, then updateComponents.
- Use realistic, domain-appropriate sample data.
- All JSON field names must be camelCase.
- Output ONLY genui protocol JSON blocks. No prose outside code fences.
- Choose components that best match the user's request.
''';
