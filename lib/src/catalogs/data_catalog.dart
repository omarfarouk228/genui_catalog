import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';

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

  /// All components in this catalog.
  static List<ComponentImplementation> get items => [
    kpiCardItem,
    dataTableItem,
    chartCardItem,
    statRowItem,
    columnItem,
    rowItem,
    listCardItem,
    emptyStateItem,
  ];

  /// Names of all components in this catalog.
  static List<String> get itemNames => items.map((i) => i.name).toList();

  /// Catalog ID agents put in a component's `catalogId`.
  static const String catalogId =
      'https://github.com/omarfarouk228/genui_catalog/catalogs/data/v1';

  /// Instructions for the agent on using these components.
  static String get instructions =>
      'Components available: ${itemNames.join(', ')}. '
      'KpiCard: single metric with optional trend. '
      'DataTable: tabular data, max 100 rows displayed (use columns+rows arrays). '
      'ChartCard: line/bar/pie chart, max 6 datasets. '
      'StatRow: up to 4 stat cards in a row. '
      'Column/Row: layout containers (children: component ids) with optional spacing and alignment. '
      'ListCard: list of tappable rows with optional icon, subtitle, trailingText, '
      'destructive flag, and dividers; a tapped row sends its event. '
      'EmptyState: centered illustration with title, description, and optional CTA button '
      'that sends actionEvent, or runs action when given.';

  /// An A2UI v1.0 catalog of these components. Register it next to the
  /// basic catalog: `MessageProcessor(catalogs: [basicCatalog(), DataCatalog.asCatalog()])`.
  static CatalogImplementation asCatalog() => CatalogImplementation(
    id: catalogId,
    protocolVersion: A2uiProtocolVersion.v1_0,
    title: 'GenUI Catalog: data',
    components: items,
    instructions: instructions,
  );
}
