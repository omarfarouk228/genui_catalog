import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/action_form.dart';

final actionFormItem = ComponentImplementation(
  name: 'ActionForm',
  schema: S.object(
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
      'requiredErrorText': S.string(),
    },
    required: ['fields'],
  ),
  builder: (context, node, props, buildChild) {
    final title = props.string('title');
    final submitLabel = props.string('submitLabel') ?? 'Submit';
    final successMessage = props.string('successMessage');

    final rawFields = props.list('fields');
    final fields = rawFields.whereType<Map<String, dynamic>>().toList();

    return ActionFormWidget(
      key: ValueKey(node.componentId),
      title: title,
      fields: fields,
      submitLabel: submitLabel,
      successMessage: successMessage,
      requiredErrorText:
          props.string('requiredErrorText') ?? '{label} is required',
      dispatchEvent: (eventName, values) {
        unawaited(
          node.context?.dispatchAction({
            'event': {'name': eventName, 'context': values},
          }),
        );
      },
    );
  },
);
