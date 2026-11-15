import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/form/checkbox_group.dart';

/// Writes the checked values to the path `values` is bound to on every
/// change, and sends its `event` as before (see `FormCatalog`).
final checkboxGroupItem = ComponentImplementation(
  name: 'CheckboxGroup',
  schema: Schema.object(
    properties: {
      'label': CatalogSchemas.text,
      'event': Schema.string(),
      'submitLabel': CatalogSchemas.text,
      'initialValues': Schema.list(items: Schema.string()),
      'values': CatalogSchemas.stringList,
      'options': Schema.list(
        items: Schema.object(
          properties: {'value': Schema.string(), 'label': Schema.string()},
          required: ['value'],
        ),
      ),
    },
    required: ['options'],
  ),
  builder: (_, node, props, _) {
    final bound = props.strings('values');
    return CheckboxGroupWidget(
      label: props.string('label'),
      event: props.string('event'),
      options: props.objects('options'),
      initialValues: bound.isNotEmpty ? bound : props.strings('initialValues'),
      submitLabel: props.string('submitLabel'),
      onChanged: (values) => props.writeBack('values', values),
      dispatchEvent: (eventName) =>
          dispatchCatalogEvent(node, props, eventName, actionKey: null),
    );
  },
);
