import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog_example/services/ai_service.dart';

void main() {
  testWidgets('renders a genui_catalog surface the model created', (
    tester,
  ) async {
    // Building the service builds the Gemini prompt from the catalog.
    final service = AiService(apiKey: 'test-key');
    addTearDown(service.dispose);
    final surfaceIds = <String>[];
    service.onSurfaceAdded = surfaceIds.add;

    service.processor.processMessages([
      {
        'version': 'v0.9',
        'createSurface': {'surfaceId': 'example', 'catalogId': 'genui_catalog'},
      },
      {
        'version': 'v0.9',
        'updateComponents': {
          'surfaceId': 'example',
          'components': [
            {
              'id': 'root',
              'component': 'KpiCard',
              'title': 'Revenue',
              'value': r'$12,450',
              'trend': 'up',
            },
          ],
        },
      },
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: A2uiSurface(
            surface: service.processor.model.getSurface('example')!,
          ),
        ),
      ),
    );

    expect(surfaceIds, ['example']);
    expect(find.text('Revenue'), findsOneWidget);
  });
}
