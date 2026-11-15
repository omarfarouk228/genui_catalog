import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';

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

/// Catalog of form components: forms, search, rating, selects, checkboxes, switches.
class FormCatalog {
  FormCatalog._();

  /// All components in this catalog.
  static List<ComponentImplementation> get items => [
    actionFormItem,
    searchBarItem,
    ratingInputItem,
    selectInputItem,
    checkboxGroupItem,
    switchGroupItem,
  ];

  /// Names of all components in this catalog.
  static List<String> get itemNames => items.map((i) => i.name).toList();

  /// Catalog ID agents put in a component's `catalogId`.
  static const String catalogId =
      'https://github.com/omarfarouk228/genui_catalog/catalogs/form/v1';

  /// Instructions for the agent on using these components.
  static String get instructions =>
      'Components available: ${itemNames.join(', ')}. '
      'Input values can be bound to the data model with {"@path": "/x"}: '
      'value on SearchBar, SelectInput and RatingInput; values on CheckboxGroup, '
      'SwitchGroup and ActionForm. The component writes the user\'s input there. '
      'ActionForm: form with typed fields (text|email|number|textarea) and a submit button; '
      'sends form_submit with the field values as context. Optional requiredErrorText ({label} placeholder). '
      'SearchBar: debounced search input; sends search_query with {query}. '
      'RatingInput: star rating 1-10, optional half-stars; sends rating_submitted '
      'with {rating, maxStars}. '
      'ActionForm, SearchBar and RatingInput run their action instead when one is given. '
      'SelectInput: dropdown for picking one value from a list of options; '
      'sends event:<value> on selection. '
      'CheckboxGroup: multi-select checkboxes; sends event:<comma-separated values>. '
      'SwitchGroup: list of on/off toggles; sends event:<value>:<on|off> per toggle. '
      'Set submitLabel on CheckboxGroup or SwitchGroup to send the selection once, '
      'from a button, as event:<comma-separated values>.';

  /// An A2UI v1.0 catalog of these components. Register it next to the
  /// basic catalog: `MessageProcessor(catalogs: [basicCatalog(), FormCatalog.asCatalog()])`.
  static CatalogImplementation asCatalog() => CatalogImplementation(
    id: catalogId,
    protocolVersion: A2uiProtocolVersion.v1_0,
    title: 'GenUI Catalog: form',
    components: items,
    instructions: instructions,
  );
}
