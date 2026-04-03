/// GenUI Catalog - Ready-to-use CatalogItems for building dynamic AI-generated UIs.
///
/// This package provides high-level business components on top of the `genui` SDK.
/// Use [GenUICatalog.all] to get a [Catalog] containing all available items, or
/// use the individual sub-catalogs ([DataCatalog], [WorkflowCatalog], [FormCatalog],
/// [MediaCatalog]) for more granular control.
library genui_catalog;

export 'package:genui/genui.dart' show Catalog, CatalogItem, DataContext;

export 'src/catalogs/data_catalog.dart';
export 'src/catalogs/workflow_catalog.dart';
export 'src/catalogs/form_catalog.dart';
export 'src/catalogs/media_catalog.dart';

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
///   catalogs: [
///     BasicCatalogItems.asCatalog(),
///     GenUICatalog.all,
///   ],
/// );
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

  /// A [Catalog] containing every item from all sub-catalogs.
  static Catalog get all => asCatalog();

  /// Creates a [Catalog] from all sub-catalog items.
  static Catalog asCatalog() => Catalog(allItems);
}
