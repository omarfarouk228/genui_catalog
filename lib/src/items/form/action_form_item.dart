import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../catalog_events.dart';
import '../../widgets/form/action_form.dart';

/// On submit, writes `{key: value}` for every field to the path `values` is
/// bound to, then sends `form_submit` with the same map as its context, or
/// runs `action` when the agent declares one.
final actionFormItem = ComponentImplementation(
  name: 'ActionForm',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'fields': Schema.list(
        items: Schema.object(
          properties: {
            'key': Schema.string(),
            'label': Schema.string(),
            'type': Schema.string(),
            'placeholder': Schema.string(),
            'required': Schema.boolean(),
          },
          required: ['key', 'label'],
        ),
      ),
      'submitLabel': CatalogSchemas.text,
      'successMessage': CatalogSchemas.text,
      'requiredErrorText': CatalogSchemas.text,
      'values': CatalogSchemas.binding,
      'action': CatalogSchemas.action,
    },
    required: ['fields'],
  ),
  builder: (_, node, props, _) => ActionFormWidget(
    title: props.string('title'),
    fields: props.objects('fields'),
    submitLabel: props.string('submitLabel') ?? 'Submit',
    successMessage: props.string('successMessage'),
    requiredErrorText:
        props.string('requiredErrorText') ?? '{label} is required',
    dispatchEvent: (_, values) {
      props.writeBack('values', values);
      dispatchCatalogEvent(
        node,
        props,
        CatalogEvents.formSubmit,
        context: values,
      );
    },
  ),
);
