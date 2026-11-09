import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/empty_state.dart';

final emptyStateItem = ComponentImplementation(
  name: 'EmptyState',
  schema: S.object(
    properties: {
      'title': S.string(),
      'description': S.string(),
      'icon': S.string(),
      'actionLabel': S.string(),
      'actionEvent': S.string(),
    },
  ),
  builder: (context, node, props, buildChild) {
    return EmptyStateWidget(
      key: ValueKey(node.componentId),
      title: props.string('title'),
      description: props.string('description'),
      iconName: props.string('icon'),
      actionLabel: props.string('actionLabel'),
      actionEvent: props.string('actionEvent'),
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
