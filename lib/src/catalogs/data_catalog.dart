import 'package:genui/genui.dart';
import '../items/data/kpi_card_item.dart';
import '../items/data/data_table_item.dart';
import '../items/data/chart_card_item.dart';
import '../items/data/stat_row_item.dart';
import '../items/data/flex_layout_item.dart';
import '../items/data/list_card_item.dart';
import '../items/data/empty_state_item.dart';

export '../items/data/kpi_card_item.dart';
export '../items/data/data_table_item.dart';
export '../items/data/chart_card_item.dart';
export '../items/data/stat_row_item.dart';
export '../items/data/flex_layout_item.dart';
export '../items/data/list_card_item.dart';
export '../items/data/empty_state_item.dart';

/// Catalog of data-display components: KPI cards, tables, charts, and stat rows.
class DataCatalog {
  DataCatalog._();

  /// All items in the data catalog.
  static List<CatalogItem> get items => [
    kpiCardItem,
    dataTableItem,
    chartCardItem,
    statRowItem,
    columnItem,
    rowItem,
    listCardItem,
    emptyStateItem,
  ];

  /// Names of all available data components.
  static List<String> get itemNames => items.map((i) => i.name).toList();

  /// Catalog ID for data components in the GenUI Catalog.
  static const String catalogId = 'genui_catalog/data';

  /// Returns a [Catalog] containing all data catalog items.
  static Catalog asCatalog() => Catalog(
    items,
    catalogId: catalogId,
    systemPromptFragments: [
      'Data display components available: ${itemNames.join(', ')}. '
          'KpiCard: single metric with optional trend. '
          'DataTable: tabular data, max 100 rows displayed (use columns+rows arrays). '
          'ChartCard: line/bar/pie chart, max 6 datasets. '
          'StatRow: up to 4 stat cards in a row. '
          'Column/Row: layout containers with optional spacing and alignment. '
          'ListCard: list of tappable rows with optional icon, subtitle, trailingText, '
          'destructive flag, and dividers. '
          'EmptyState: centered illustration with title, description, and optional CTA button.',
    ],
  );
}
