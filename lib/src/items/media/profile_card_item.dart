import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/media/profile_card.dart';

final profileCardItem = ComponentImplementation(
  name: 'ProfileCard',
  schema: S.object(
    properties: {
      'name': S.string(),
      'role': S.string(),
      'avatarUrl': S.string(),
      'details': S.list(
        items: S.object(
          properties: {'label': S.string(), 'value': S.string()},
          required: ['label', 'value'],
        ),
      ),
      'actions': S.list(
        items: S.object(
          properties: {'label': S.string(), 'event': S.string()},
          required: ['label', 'event'],
        ),
      ),
    },
    required: ['name'],
  ),
  builder: (context, node, props, buildChild) {
    final name = props.string('name') ?? '';
    final role = props.string('role');
    final avatarUrl = props.string('avatarUrl');

    final rawDetails = props.list('details');
    final details = rawDetails.whereType<Map<String, dynamic>>().toList();

    final rawActions = props.list('actions');
    final actions = rawActions.whereType<Map<String, dynamic>>().toList();

    return ProfileCardWidget(
      key: ValueKey(node.componentId),
      name: name,
      role: role,
      avatarUrl: avatarUrl,
      details: details,
      actions: actions,
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
