import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/switch_group.dart';

final switchGroupItem = ComponentImplementation(
  name: 'SwitchGroup',
  schema: S.object(
    properties: {
      'label': S.string(),
      'event': S.string(),
      'submitLabel': S.string(),
      'initialValues': S.list(items: S.string()),
      'options': S.list(
        items: S.object(
          properties: {
            'value': S.string(),
            'label': S.string(),
            'subtitle': S.string(),
          },
          required: ['value'],
        ),
      ),
    },
    required: ['options'],
  ),
  builder: (context, node, props, buildChild) {
    final rawOptions = props.list('options');
    final options = rawOptions.whereType<Map<String, dynamic>>().toList();
    final rawInitial = props.list('initialValues');
    final initialValues = rawInitial.whereType<String>().toList();

    return SwitchGroupWidget(
      key: ValueKey(node.componentId),
      label: props.string('label'),
      event: props.string('event'),
      options: options,
      initialValues: initialValues,
      submitLabel: props.string('submitLabel'),
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
