import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/workflow/stepper_card.dart';

/// Navigation sends `next_step` and `prev_step` (see `CatalogEvents`).
final stepperCardItem = ComponentImplementation(
  name: 'StepperCard',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'steps': Schema.list(
        items: Schema.object(
          properties: {
            'title': Schema.string(),
            'description': Schema.string(),
            'completed': Schema.boolean(),
          },
          required: ['title'],
        ),
      ),
      'currentStep': Schema.integer(),
      'showNavigation': Schema.boolean(),
      'previousLabel': CatalogSchemas.text,
      'nextLabel': CatalogSchemas.text,
    },
    required: ['steps', 'currentStep'],
  ),
  builder: (_, node, props, _) => StepperCardWidget(
    title: props.string('title'),
    steps: props.objects('steps'),
    initialStep: props.integer('currentStep') ?? 0,
    showNavigation: props.boolean('showNavigation') ?? false,
    previousLabel: props.string('previousLabel') ?? 'Previous',
    nextLabel: props.string('nextLabel') ?? 'Next',
    dispatchEvent: (eventName) =>
        dispatchCatalogEvent(node, props, eventName, actionKey: null),
  ),
);
