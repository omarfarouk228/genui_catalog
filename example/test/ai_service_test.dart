import 'dart:convert';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/genui_catalog.dart';
import 'package:genui_catalog_example/services/ai_service.dart';

/// A reply in the agent SDK's direct JSON format, as Gemini would write it.
final String _reply =
    'Here is your feedback form.\n<a2ui-json>${jsonEncode([
      {
        'version': '1.0',
        'createSurface': {
          'surfaceId': 'feedback',
          'catalogId': GenUICatalog.catalogId,
          'sendDataModel': true,
          'components': [
            {
              'id': 'root',
              'component': 'Column',
              'children': ['kpi', 'stars'],
            },
            {'id': 'kpi', 'component': 'KpiCard', 'title': 'NPS', 'value': '72'},
            {
              'id': 'stars',
              'component': 'RatingInput',
              'title': 'App experience',
              'value': {'@path': '/rating'},
            },
          ],
          'dataModel': {'rating': 0},
        },
      },
    ])}</a2ui-json>';

/// Streams [text] in small chunks, as a model does.
Stream<String> _chunked(String text) async* {
  for (var i = 0; i < text.length; i += 40) {
    yield text.substring(i, i + 40 > text.length ? text.length : i + 40);
  }
}

void main() {
  testWidgets('renders the streamed reply and sends actions back', (
    tester,
  ) async {
    final turns = <String>[];
    late String systemPrompt;
    final service = AiService.withModel((prompt) {
      systemPrompt = prompt;
      return (turn) {
        turns.add(turn);
        return turns.length == 1 ? _chunked(_reply) : const Stream.empty();
      };
    });
    addTearDown(service.dispose);
    final surfaces = <String>[];
    Object? error;
    service
      ..onSurfaceAdded = surfaces.add
      ..onError = (e) => error = e;

    expect(systemPrompt, contains('RatingInput'));
    expect(systemPrompt, contains(GenUICatalog.catalogId));

    await tester.runAsync(() => service.send('Feedback form please'));
    expect(error, isNull);
    expect(surfaces, ['feedback']);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: A2uiSurface(surface: service.surface('feedback')!),
          ),
        ),
      ),
    );
    expect(find.text('NPS'), findsOneWidget);
    expect(find.text('App experience'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_border).at(3));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));

    expect(turns, hasLength(2));
    final Map<String, dynamic> turn = jsonDecode(turns[1]);
    final String sent = jsonEncode(turn['a2ui']);
    expect(sent, contains(CatalogEvents.ratingSubmitted));
    expect(
      jsonEncode(turn['metadata']['a2uiRendererDataModel']),
      contains('"rating":4'),
    );
  });
}
