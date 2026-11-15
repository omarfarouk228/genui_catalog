import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const String testSurfaceId = 'main';
const String testCatalogId = 'https://example.com/genui_catalog/test.json';

Widget wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

/// A v1.0 catalog holding only [components], for tests.
CatalogImplementation testCatalog(List<ComponentImplementation> components) =>
    CatalogImplementation(
      id: testCatalogId,
      protocolVersion: A2uiProtocolVersion.v1_0,
      components: components,
    );

/// Renders one A2UI v1.0 surface and records its actions and errors.
class A2uiHarness {
  A2uiHarness._(this.processor);

  final MessageProcessor<ComponentImplementation> processor;
  final List<A2uiRendererAction> actions = [];
  final List<A2uiRendererError> errors = [];

  SurfaceModel<ComponentImplementation> get surface =>
      processor.model.getSurface(testSurfaceId)!;

  Object? data(String path) => surface.dataModel.get(path);

  /// Sends `updateDataModel` for [path].
  void updateData(String path, Object? value) => processor.processMessages([
    {
      'version': '1.0',
      'updateDataModel': {
        'surfaceId': testSurfaceId,
        'path': path,
        'value': value,
      },
    },
  ]);

  /// Creates a surface on the basic catalog. Each component comes from
  /// [catalog] (`catalogId` [testCatalogId]) unless it names another one,
  /// such as `BasicCatalog.v1_0Id`.
  static Future<A2uiHarness> pump(
    WidgetTester tester, {
    required CatalogImplementation catalog,
    required List<Map<String, Object?>> components,
    Map<String, Object?>? dataModel,
    ValidationConfig? validationConfig = ValidationConfig.strict,
  }) async {
    final harness = A2uiHarness._(
      MessageProcessor<ComponentImplementation>(
        catalogs: [basicCatalog(), catalog],
        validationConfig: validationConfig,
      ),
    );
    final model = harness.processor.model;
    model.onAction.subscribe(harness.actions.add);
    model.onSurfaceCreated.subscribe(
      (surface) => surface.onError.subscribe(harness.errors.add),
    );
    addTearDown(model.dispose);

    harness.processor.processMessages([
      {
        'version': '1.0',
        'createSurface': {
          'surfaceId': testSurfaceId,
          'catalogId': BasicCatalog.v1_0Id,
          'components': [
            for (final c in components) {'catalogId': testCatalogId, ...c},
          ],
          'dataModel': ?dataModel,
        },
      },
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: A2uiSurface(surface: harness.surface),
          ),
        ),
      ),
    );
    return harness;
  }
}

/// Renders [item] as the root of a surface, with [props] as its properties.
Future<A2uiHarness> pumpItem(
  WidgetTester tester,
  ComponentImplementation item,
  Map<String, Object?> props, {
  Map<String, Object?>? dataModel,
  ValidationConfig? validationConfig = ValidationConfig.strict,
}) => A2uiHarness.pump(
  tester,
  catalog: testCatalog([item]),
  dataModel: dataModel,
  validationConfig: validationConfig,
  components: [
    {'id': 'root', 'component': item.name, ...props},
  ],
);
