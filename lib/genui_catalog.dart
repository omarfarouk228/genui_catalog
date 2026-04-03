/// GenUI Catalog - Ready-to-use CatalogItems for building dynamic AI-generated UIs.
///
/// This package provides high-level business components on top of the `genui` SDK.
/// Use [GenUICatalog.all] to get a [Catalog] containing all available items, or
/// use the individual sub-catalogs ([DataCatalog], [WorkflowCatalog], [FormCatalog],
/// [MediaCatalog]) for more granular control.
library;

export 'package:genui/genui.dart' show Catalog, CatalogItem, DataContext;

export 'src/catalogs/data_catalog.dart';
export 'src/catalogs/workflow_catalog.dart';
export 'src/catalogs/form_catalog.dart';
export 'src/catalogs/media_catalog.dart';

export 'src/catalog_events.dart';
export 'src/utils/color_utils.dart';
export 'src/utils/icon_utils.dart';

import 'package:genui/genui.dart';
import 'src/catalogs/data_catalog.dart';
import 'src/catalogs/workflow_catalog.dart';
import 'src/catalogs/form_catalog.dart';
import 'src/catalogs/media_catalog.dart';

/// Top-level catalog combining all four sub-catalogs.
///
/// Usage:
/// ```dart
/// SurfaceController(
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

  /// All [CatalogItem]s from every sub-catalog combined.
  static List<CatalogItem> get allItems => [
    ...DataCatalog.items,
    ...WorkflowCatalog.items,
    ...FormCatalog.items,
    ...MediaCatalog.items,
  ];

  /// Names of all registered catalog items. Useful for generating prompts or
  /// validating AI-generated component references.
  static List<String> get itemNames => allItems.map((i) => i.name).toList();

  /// Finds a [CatalogItem] by name, or returns `null` if not found.
  ///
  /// Name matching is case-sensitive and must be exact.
  static CatalogItem? findItem(String name) {
    try {
      return allItems.firstWhere((item) => item.name == name);
    } catch (_) {
      return null;
    }
  }

  /// A [Catalog] containing every item from all sub-catalogs.
  static Catalog get all => asCatalog();

  /// Catalog ID for the combined GenUI Catalog.
  static const String catalogId = 'genui_catalog';

  /// Creates a [Catalog] from all sub-catalog items, with system prompt
  /// fragments automatically generated from each sub-catalog's metadata.
  static Catalog asCatalog() => Catalog(
    allItems,
    catalogId: catalogId,
    systemPromptFragments: [
      'Available components: ${itemNames.join(', ')}.',
      ...DataCatalog.asCatalog().systemPromptFragments,
      ...WorkflowCatalog.asCatalog().systemPromptFragments,
      ...FormCatalog.asCatalog().systemPromptFragments,
      ...MediaCatalog.asCatalog().systemPromptFragments,
    ],
  );
}
