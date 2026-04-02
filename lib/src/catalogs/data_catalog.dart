import 'package:genui/genui.dart';
import '../items/data/kpi_card_item.dart';
import '../items/data/data_table_item.dart';
import '../items/data/chart_card_item.dart';
import '../items/data/stat_row_item.dart';

export '../items/data/kpi_card_item.dart';
export '../items/data/data_table_item.dart';
export '../items/data/chart_card_item.dart';
export '../items/data/stat_row_item.dart';

/// Catalog of data-display components: KPI cards, tables, charts, and stat rows.
class DataCatalog {
  DataCatalog._();

  /// All items in the data catalog.
  static List<CatalogItem> get items => [
        kpiCardItem,
        dataTableItem,
        chartCardItem,
        statRowItem,
      ];

  /// Returns a [Catalog] containing all data catalog items.
  static Catalog asCatalog() => Catalog(items: items);
}
