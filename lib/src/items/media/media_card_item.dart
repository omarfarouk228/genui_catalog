import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/media/media_card.dart';

/// Each action button sends its `event` as-is.
final mediaCardItem = ComponentImplementation(
  name: 'MediaCard',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'content': CatalogSchemas.text,
      'imageUrl': CatalogSchemas.text,
      'tags': Schema.list(items: Schema.string()),
      'actions': Schema.list(
        items: Schema.object(
          properties: {'label': Schema.string(), 'event': Schema.string()},
          required: ['label', 'event'],
        ),
      ),
    },
    required: ['title'],
  ),
  builder: (_, node, props, _) => MediaCardWidget(
    title: props.string('title') ?? '',
    content: props.string('content'),
    imageUrl: props.string('imageUrl'),
    tags: props.strings('tags'),
    actions: props.objects('actions'),
    dispatchEvent: (eventName) =>
        dispatchCatalogEvent(node, props, eventName, actionKey: null),
  ),
);
