import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/workflow/timeline_card.dart';

final timelineCardItem = CatalogItem(
  name: 'TimelineCard',
  dataSchema: S.object(
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
  widgetBuilder: ({
    required Map<String, Object?> data,
    required String id,
    required Widget Function(Widget) buildChild,
    required Function(String event) dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final title = data['title'] as String?;
    final rawEvents = data['events'] as List<dynamic>? ?? [];
    final events = rawEvents
        .whereType<Map<String, dynamic>>()
        .toList();

    return TimelineCardWidget(
      key: ValueKey(id),
      title: title,
      events: events,
    );
  },
);
