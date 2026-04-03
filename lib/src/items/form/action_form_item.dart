import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/action_form.dart';

final actionFormItem = CatalogItem(
  name: 'ActionForm',
  dataSchema: S.object(
    properties: {
      'title': S.string(),
      'fields': S.list(
        items: S.object(
          properties: {
            'key': S.string(),
            'label': S.string(),
            'type': S.string(),
            'placeholder': S.string(),
            'required': S.boolean(),
          },
          required: ['key', 'label'],
        ),
      ),
      'submitLabel': S.string(),
      'successMessage': S.string(),
    },
    required: ['fields'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final title = data['title'] as String?;
    final submitLabel = data['submitLabel'] as String? ?? 'Submit';
    final successMessage = data['successMessage'] as String?;

    final rawFields = data['fields'] as List<dynamic>? ?? [];
    final fields = rawFields.whereType<Map<String, dynamic>>().toList();

    return ActionFormWidget(
      key: ValueKey(itemContext.id),
      title: title,
      fields: fields,
      submitLabel: submitLabel,
      successMessage: successMessage,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
