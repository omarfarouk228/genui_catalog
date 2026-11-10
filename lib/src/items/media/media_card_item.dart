import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/media/media_card.dart';

final mediaCardItem = ComponentImplementation(
  name: 'MediaCard',
  schema: S.object(
    properties: {
      'title': S.string(),
      'content': S.string(),
      'imageUrl': S.string(),
      'tags': S.list(items: S.string()),
      'actions': S.list(
        items: S.object(
          properties: {'label': S.string(), 'event': S.string()},
          required: ['label', 'event'],
        ),
      ),
    },
    required: ['title'],
  ),
  builder: (context, node, props, buildChild) {
    final title = props.string('title') ?? '';
    final content = props.string('content');
    final imageUrl = props.string('imageUrl');

    final rawTags = props.list('tags');
    final tags = rawTags.map((e) => e.toString()).toList();

    final rawActions = props.list('actions');
    final actions = rawActions.whereType<Map<String, dynamic>>().toList();

    return MediaCardWidget(
      key: ValueKey(node.componentId),
      title: title,
      content: content,
      imageUrl: imageUrl,
      tags: tags,
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
