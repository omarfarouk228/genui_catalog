import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/search_bar_widget.dart';

final searchBarItem = CatalogItem(
  name: 'SearchBar',
  dataSchema: S.object(
    properties: {
      'placeholder': S.string(),
      'debounceMs': S.integer(),
      'minChars': S.integer(),
    },
    required: [],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final placeholder = data['placeholder'] as String?;
    final debounceMs = data['debounceMs'] as int? ?? 300;
    final minChars = data['minChars'] as int? ?? 2;

    return SearchBarWidget(
      key: ValueKey(itemContext.id),
      placeholder: placeholder,
      debounceMs: debounceMs,
      minChars: minChars,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
