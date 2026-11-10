import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The processor behind a surface [pumpComponents] rendered, and the actions
/// the surface dispatched.
typedef SurfaceHarness = ({
  MessageProcessor<ComponentImplementation> processor,
  List<A2uiRendererAction> actions,
});

/// Renders [components] on a surface whose catalog holds [items], under the
/// strict validation that reports schema mistakes as errors.
///
/// Throws the [A2uiError] the processor reports for components it rejects.
Future<SurfaceHarness> pumpComponents(
  WidgetTester tester,
  List<ComponentImplementation> items,
  List<Map<String, Object?>> components,
) async {
  const catalogId = 'genui_catalog/test';
  const surfaceId = 'surface-1';
  final processor = MessageProcessor<ComponentImplementation>(
    catalogs: [CatalogImplementation(id: catalogId, components: items)],
    validationConfig: ValidationConfig.strict,
  );
  addTearDown(processor.dispose);
  final actions = <A2uiRendererAction>[];
  processor.model.onAction.subscribe(actions.add);
  processor.processMessages([
    {
      'version': 'v0.9',
      'createSurface': {'surfaceId': surfaceId, 'catalogId': catalogId},
    },
    {
      'version': 'v0.9',
      'updateComponents': {'surfaceId': surfaceId, 'components': components},
    },
  ]);
  await tester.pumpWidget(
    wrap(A2uiSurface(surface: processor.model.getSurface(surfaceId)!)),
  );
  return (processor: processor, actions: actions);
}

/// Renders [item] as the root of a surface, with [data] as its properties.
Future<SurfaceHarness> pumpItem(
  WidgetTester tester,
  ComponentImplementation item, {
  Map<String, Object?> data = const {},
}) => pumpComponents(
  tester,
  [item],
  [
    {'id': 'root', 'component': item.name, ...data},
  ],
);

Widget wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
