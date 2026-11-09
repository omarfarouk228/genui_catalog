import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/workflow/timeline_card.dart';

final timelineCardItem = ComponentImplementation(
  name: 'TimelineCard',
  schema: S.object(
    properties: {
      'title': S.string(),
      'events': S.list(
        items: S.object(
          properties: {
            'time': S.string(),
            'title': S.string(),
            'description': S.string(),
            'status': S.string(),
          },
          required: ['title'],
        ),
      ),
    },
    required: ['events'],
  ),
  builder: (context, node, props, buildChild) {
    final title = props.string('title');
    final rawEvents = props.list('events');
    final events = rawEvents.whereType<Map<String, dynamic>>().toList();

    return TimelineCardWidget(
      key: ValueKey(node.componentId),
      title: title,
      events: events,
    );
  },
);
