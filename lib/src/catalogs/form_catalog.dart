import 'package:genui/genui.dart';
import '../items/form/action_form_item.dart';
import '../items/form/search_bar_item.dart';
import '../items/form/rating_input_item.dart';
import '../items/form/select_input_item.dart';
import '../items/form/checkbox_group_item.dart';
import '../items/form/switch_group_item.dart';

export '../items/form/action_form_item.dart';
export '../items/form/search_bar_item.dart';
export '../items/form/rating_input_item.dart';
export '../items/form/select_input_item.dart';
export '../items/form/checkbox_group_item.dart';
export '../items/form/switch_group_item.dart';

/// Catalog of form components: action forms, search bars, and rating inputs.
class FormCatalog {
  FormCatalog._();

  /// All items in the form catalog.
  static List<CatalogItem> get items => [
    actionFormItem,
    searchBarItem,
    ratingInputItem,
    selectInputItem,
    checkboxGroupItem,
    switchGroupItem,
  ];

  /// Names of all available form components.
  static List<String> get itemNames => items.map((i) => i.name).toList();

  /// Catalog ID for form components in the GenUI Catalog.
  static const String catalogId = 'genui_catalog/form';

  /// Returns a [Catalog] containing all form catalog items.
  static Catalog asCatalog() => Catalog(
    items,
    catalogId: catalogId,
    systemPromptFragments: [
      'Form components available: ${itemNames.join(', ')}. '
          'ActionForm: form with typed fields (text|email|number|textarea) and a submit button; '
          'dispatches form_submit event. '
          'SearchBar: debounced search input; dispatches search_query event. '
          'RatingInput: star rating 1–10, optional half-stars; dispatches rating_submitted event. '
          'SelectInput: dropdown for picking one value from a list of options; '
          'dispatches event:<value> on selection. '
          'CheckboxGroup: multi-select checkboxes; dispatches event:<comma-separated values>. '
          'SwitchGroup: list of on/off toggles; dispatches event:<value>:<on|off> per toggle.',
    ],
  );
}
