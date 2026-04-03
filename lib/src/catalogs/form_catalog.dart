import 'package:genui/genui.dart';
import '../items/form/action_form_item.dart';
import '../items/form/search_bar_item.dart';
import '../items/form/rating_input_item.dart';

export '../items/form/action_form_item.dart';
export '../items/form/search_bar_item.dart';
export '../items/form/rating_input_item.dart';

/// Catalog of form components: action forms, search bars, and rating inputs.
class FormCatalog {
  FormCatalog._();

  /// All items in the form catalog.
  static List<CatalogItem> get items => [
    actionFormItem,
    searchBarItem,
    ratingInputItem,
  ];

  /// Returns a [Catalog] containing all form catalog items.
  static Catalog asCatalog() => Catalog(items);
}
