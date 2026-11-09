import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/workflow/stepper_card.dart';

final stepperCardItem = ComponentImplementation(
  name: 'StepperCard',
  schema: S.object(
    properties: {
      'title': S.string(),
      'steps': S.list(
        items: S.object(
          properties: {
            'title': S.string(),
            'description': S.string(),
            'completed': S.boolean(),
          },
          required: ['title'],
        ),
      ),
      'currentStep': S.integer(),
      'showNavigation': S.boolean(),
      'previousLabel': S.string(),
      'nextLabel': S.string(),
    },
    required: ['steps', 'currentStep'],
  ),
  builder: (context, node, props, buildChild) {
    final title = props.string('title');
    final currentStep = props.number('currentStep')?.toInt() ?? 0;
    final showNavigation = props.boolean('showNavigation') ?? false;

    final rawSteps = props.list('steps');
    final steps = rawSteps.whereType<Map<String, dynamic>>().toList();

    return StepperCardWidget(
      key: ValueKey(node.componentId),
      title: title,
      steps: steps,
      initialStep: currentStep,
      showNavigation: showNavigation,
      previousLabel: props.string('previousLabel') ?? 'Previous',
      nextLabel: props.string('nextLabel') ?? 'Next',
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
