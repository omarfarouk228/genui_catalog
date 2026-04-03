import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/workflow/stepper_card.dart';

final stepperCardItem = CatalogItem(
  name: 'StepperCard',
  dataSchema: S.object(
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
    },
    required: ['steps', 'currentStep'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final title = data['title'] as String?;
    final currentStep = data['currentStep'] as int? ?? 0;
    final showNavigation = data['showNavigation'] as bool? ?? false;

    final rawSteps = data['steps'] as List<dynamic>? ?? [];
    final steps = rawSteps.whereType<Map<String, dynamic>>().toList();

    return StepperCardWidget(
      key: ValueKey(itemContext.id),
      title: title,
      steps: steps,
      initialStep: currentStep,
      showNavigation: showNavigation,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
