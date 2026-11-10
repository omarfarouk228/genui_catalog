import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/list_card.dart';

final listCardItem = ComponentImplementation(
  name: 'ListCard',
  schema: S.object(
    properties: {
      'title': S.string(),
      'showDividers': S.boolean(),
      'items': S.list(
        items: S.object(
          properties: {
            'title': S.string(),
            'subtitle': S.string(),
            'icon': S.string(),
            'trailingText': S.string(),
            'event': S.string(),
            'destructive': S.boolean(),
          },
          required: ['title'],
        ),
      ),
    },
    required: ['items'],
  ),
  builder: (context, node, props, buildChild) {
    final rawItems = props.list('items');
    final items = rawItems.whereType<Map<String, dynamic>>().toList();

    return ListCardWidget(
      key: ValueKey(node.componentId),
      title: props.string('title'),
      showDividers: props.boolean('showDividers') ?? true,
      items: items,
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
