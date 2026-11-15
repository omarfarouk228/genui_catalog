import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../catalog_events.dart';
import '../../widgets/form/search_bar_widget.dart';

/// Writes the query to the path `value` is bound to, then sends
/// `search_query` with `{query}`, or runs `action` when the agent declares
/// one.
final searchBarItem = ComponentImplementation(
  name: 'SearchBar',
  schema: Schema.object(
    properties: {
      'placeholder': CatalogSchemas.text,
      'debounceMs': Schema.integer(),
      'minChars': Schema.integer(),
      'value': CatalogSchemas.text,
      'action': CatalogSchemas.action,
    },
  ),
  builder: (_, node, props, _) => SearchBarWidget(
    placeholder: props.string('placeholder'),
    debounceMs: props.integer('debounceMs') ?? 300,
    minChars: props.integer('minChars') ?? 2,
    dispatchEvent: (_, query) {
      props.writeBack('value', query);
      dispatchCatalogEvent(
        node,
        props,
        CatalogEvents.searchQuery,
        context: {'query': query},
      );
    },
  ),
);
