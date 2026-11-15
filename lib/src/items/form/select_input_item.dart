import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/form/select_input.dart';

/// Writes the selection to the path `value` is bound to, and sends
/// `<event>:<value>` when `event` is set.
final selectInputItem = ComponentImplementation(
  name: 'SelectInput',
  schema: Schema.object(
    properties: {
      'label': CatalogSchemas.text,
      'placeholder': CatalogSchemas.text,
      'initialValue': Schema.string(),
      'value': CatalogSchemas.text,
      'event': Schema.string(),
      'options': Schema.list(
        items: Schema.object(
          properties: {'value': Schema.string(), 'label': Schema.string()},
          required: ['value'],
        ),
      ),
    },
    required: ['options'],
  ),
  builder: (_, node, props, _) => SelectInputWidget(
    label: props.string('label'),
    placeholder: props.string('placeholder'),
    initialValue: props.string('value') ?? props.string('initialValue'),
    event: props.string('event'),
    options: props.objects('options'),
    onSelected: (value) => props.writeBack('value', value),
    dispatchEvent: (eventName) =>
        dispatchCatalogEvent(node, props, eventName, actionKey: null),
  ),
);
