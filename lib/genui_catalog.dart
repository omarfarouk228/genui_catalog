/// GenUI Catalog - ready-to-use A2UI components for building dynamic
/// AI-generated UIs with `a2ui_flutter`.
///
/// Use [GenUICatalog.all] to get a catalog containing every component, or
/// the individual sub-catalogs ([DataCatalog], [WorkflowCatalog],
/// [FormCatalog], [MediaCatalog]) for more granular control.
library;

export 'package:a2ui_flutter/a2ui_flutter.dart'
    show CatalogImplementation, ComponentImplementation;

export 'src/catalogs/data_catalog.dart';
export 'src/catalogs/workflow_catalog.dart';
export 'src/catalogs/form_catalog.dart';
export 'src/catalogs/media_catalog.dart';

export 'src/catalog_events.dart';
export 'src/utils/color_utils.dart';
export 'src/utils/icon_utils.dart';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';

import 'src/catalogs/data_catalog.dart';
import 'src/catalogs/workflow_catalog.dart';
import 'src/catalogs/form_catalog.dart';
import 'src/catalogs/media_catalog.dart';

/// Top-level catalog combining all four sub-catalogs.
///
/// Register it next to the basic catalog, and give the agent its id:
/// ```dart
/// final processor = MessageProcessor<ComponentImplementation>(
///   catalogs: [basicCatalog(), GenUICatalog.all],
/// );
/// ```
///
/// Listen to the actions components send, using [CatalogEvents]:
/// ```dart
/// processor.model.onAction.subscribe((action) {
///   if (action.name == CatalogEvents.formSubmit) { ... }
/// });
/// ```
class GenUICatalog {
  GenUICatalog._();

  /// All components from every sub-catalog combined.
  static List<ComponentImplementation> get allItems => [
    ...DataCatalog.items,
    ...WorkflowCatalog.items,
    ...FormCatalog.items,
    ...MediaCatalog.items,
  ];

  /// Names of all components. Useful for generating prompts or validating
  /// AI-generated component references.
  static List<String> get itemNames => allItems.map((i) => i.name).toList();

  /// Finds a component by name, or returns `null` if not found.
  ///
  /// Name matching is case-sensitive and must be exact.
  static ComponentImplementation? findItem(String name) {
    for (final item in allItems) {
      if (item.name == name) return item;
    }
    return null;
  }

  /// A catalog containing every component from all sub-catalogs.
  static CatalogImplementation get all => asCatalog();

  /// Catalog ID for the combined catalog.
  static const String catalogId =
      'https://github.com/omarfarouk228/genui_catalog/catalogs/all/v1';

  /// Instructions for the agent, combined from every sub-catalog.
  static String get instructions => [
    DataCatalog.instructions,
    WorkflowCatalog.instructions,
    FormCatalog.instructions,
    MediaCatalog.instructions,
  ].join('\n');

  /// Creates an A2UI v1.0 catalog from all sub-catalog components.
  static CatalogImplementation asCatalog() => CatalogImplementation(
    id: catalogId,
    protocolVersion: A2uiProtocolVersion.v1_0,
    title: 'GenUI Catalog',
    components: allItems,
    instructions: instructions,
  );
}
