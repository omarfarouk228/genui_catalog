import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/select_input.dart';
import '../event_property.dart';

final selectInputItem = ComponentImplementation(
  name: 'SelectInput',
  schema: S.object(
    properties: {
      'label': S.string(),
      'placeholder': S.string(),
      'initialValue': S.string(),
      'options': S.list(
        items: S.object(
          properties: {'value': S.string(), 'label': S.string()},
          required: ['value'],
        ),
      ),
    },
    patternProperties: eventPatternProperties,
    additionalProperties: true,
    required: ['options'],
  ),
  builder: (context, node, props, buildChild) {
    final rawOptions = props.list('options');
    final options = rawOptions.whereType<Map<String, dynamic>>().toList();

    return SelectInputWidget(
      key: ValueKey(node.componentId),
      label: props.string('label'),
      placeholder: props.string('placeholder'),
      initialValue: props.string('initialValue'),
      event: props.string('event'),
      options: options,
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
