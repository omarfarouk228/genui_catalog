import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/search_bar_widget.dart';

final searchBarItem = ComponentImplementation(
  name: 'SearchBar',
  schema: S.object(
    properties: {
      'placeholder': S.string(),
      'debounceMs': S.integer(),
      'minChars': S.integer(),
    },
    required: [],
  ),
  builder: (context, node, props, buildChild) {
    final placeholder = props.string('placeholder');
    final debounceMs = props.number('debounceMs')?.toInt() ?? 300;
    final minChars = props.number('minChars')?.toInt() ?? 2;

    return SearchBarWidget(
      key: ValueKey(node.componentId),
      placeholder: placeholder,
      debounceMs: debounceMs,
      minChars: minChars,
      dispatchEvent: (eventName) {
        unawaited(
          node.context?.dispatchAction({
            'event': {'name': eventName},
          }),
        );
      },
    );
  },
);
