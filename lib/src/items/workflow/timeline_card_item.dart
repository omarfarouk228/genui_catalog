import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/workflow/timeline_card.dart';

final timelineCardItem = ComponentImplementation(
  name: 'TimelineCard',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'events': Schema.list(
        items: Schema.object(
          properties: {
            'time': Schema.string(),
            'title': Schema.string(),
            'description': Schema.string(),
            'status': Schema.string(),
          },
          required: ['title'],
        ),
      ),
    },
    required: ['events'],
  ),
  builder: (_, _, props, _) => TimelineCardWidget(
    title: props.string('title'),
    events: props.objects('events'),
  ),
);
