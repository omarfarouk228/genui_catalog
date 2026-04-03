import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/checkbox_group.dart';

final checkboxGroupItem = CatalogItem(
  name: 'CheckboxGroup',
  dataSchema: S.object(
    properties: {
      'label': S.string(),
      'event': S.string(),
      'initialValues': S.list(items: S.string()),
      'options': S.list(
        items: S.object(
          properties: {
            'value': S.string(),
            'label': S.string(),
          },
          required: ['value'],
        ),
      ),
    },
    required: ['options'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final rawOptions = data['options'] as List<dynamic>? ?? [];
    final options = rawOptions.whereType<Map<String, dynamic>>().toList();
    final rawInitial = data['initialValues'] as List<dynamic>? ?? [];
    final initialValues = rawInitial.whereType<String>().toList();

    return CheckboxGroupWidget(
      key: ValueKey(itemContext.id),
      label: data['label'] as String?,
      event: data['event'] as String?,
      options: options,
      initialValues: initialValues,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
