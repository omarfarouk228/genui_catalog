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
  widgetBuilder: ({
    required Map<String, Object?> data,
    required String id,
    required Widget Function(Widget) buildChild,
    required Function(String event) dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final title = data['title'] as String?;
    final submitLabel = data['submitLabel'] as String? ?? 'Submit';
    final successMessage = data['successMessage'] as String?;

    final rawFields = data['fields'] as List<dynamic>? ?? [];
    final fields = rawFields
        .whereType<Map<String, dynamic>>()
        .toList();

    return ActionFormWidget(
      key: ValueKey(id),
      title: title,
      fields: fields,
      submitLabel: submitLabel,
      successMessage: successMessage,
      dispatchEvent: dispatchEvent,
    );
  },
);
