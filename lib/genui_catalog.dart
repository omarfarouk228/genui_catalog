/// GenUI Catalog - Ready-to-use A2UI components for building dynamic AI-generated UIs.
///
/// This package provides high-level business components on top of the `a2ui_flutter` SDK.
/// Use [GenUICatalog.all] to get a [CatalogImplementation] containing all available items, or
/// use the individual sub-catalogs ([DataCatalog], [WorkflowCatalog], [FormCatalog],
/// [MediaCatalog]) for more granular control.
library;

export 'package:a2ui_core/a2ui_core.dart' show Catalog, DataContext;
export 'package:a2ui_flutter/a2ui_flutter.dart'
    show CatalogImplementation, ComponentImplementation;

export 'src/catalogs/data_catalog.dart';
export 'src/catalogs/workflow_catalog.dart';
export 'src/catalogs/form_catalog.dart';
export 'src/catalogs/media_catalog.dart';

export 'src/catalog_events.dart';
export 'src/utils/color_utils.dart';
export 'src/utils/icon_utils.dart';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'src/catalogs/data_catalog.dart';
import 'src/catalogs/workflow_catalog.dart';
import 'src/catalogs/form_catalog.dart';
import 'src/catalogs/media_catalog.dart';

/// Top-level catalog combining all four sub-catalogs.
///
/// Usage:
/// ```dart
/// MessageProcessor<ComponentImplementation>(
///   catalogs: [GenUICatalog.all],
/// );
/// ```
///
/// Listen to dispatched events using [CatalogEvents] constants:
/// ```dart
/// if (event.name == CatalogEvents.formSubmit) { ... }
/// ```
class GenUICatalog {
  GenUICatalog._();

  /// All [ComponentImplementation]s from every sub-catalog combined.
  static List<ComponentImplementation> get allItems => [
    ...DataCatalog.items,
    ...WorkflowCatalog.items,
    ...FormCatalog.items,
    ...MediaCatalog.items,
  ];

  /// Names of all registered catalog items. Useful for generating prompts or
  /// validating AI-generated component references.
  static List<String> get itemNames => allItems.map((i) => i.name).toList();

  /// Finds a [ComponentImplementation] by name, or returns `null` if not found.
  ///
  /// Name matching is case-sensitive and must be exact.
  static ComponentImplementation? findItem(String name) {
    try {
      return allItems.firstWhere((item) => item.name == name);
    } catch (_) {
      return null;
    }
  }

  /// A [CatalogImplementation] containing every item from all sub-catalogs.
  static CatalogImplementation get all => asCatalog();

  /// Catalog ID for the combined GenUI Catalog.
  static const String catalogId = 'genui_catalog';

  /// Creates a [CatalogImplementation] from all sub-catalog items, with
  /// instructions automatically generated from each sub-catalog's metadata.
  static CatalogImplementation asCatalog() => CatalogImplementation(
    id: catalogId,
    components: allItems,
    instructions: [
      'Available components: ${itemNames.join(', ')}.',
      ?DataCatalog.asCatalog().instructions,
      ?WorkflowCatalog.asCatalog().instructions,
      ?FormCatalog.asCatalog().instructions,
      ?MediaCatalog.asCatalog().instructions,
    ].join('\n'),
  );
}
