import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/select_input.dart';

final selectInputItem = CatalogItem(
  name: 'SelectInput',
  dataSchema: S.object(
    properties: {
      'label': S.string(),
      'placeholder': S.string(),
      'initialValue': S.string(),
      'event': S.string(),
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

    return SelectInputWidget(
      key: ValueKey(itemContext.id),
      label: data['label'] as String?,
      placeholder: data['placeholder'] as String?,
      initialValue: data['initialValue'] as String?,
      event: data['event'] as String?,
      options: options,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
