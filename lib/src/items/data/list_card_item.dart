import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/data/list_card.dart';

/// Each item's `event` is sent as-is when the item is tapped.
final listCardItem = ComponentImplementation(
  name: 'ListCard',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'showDividers': Schema.boolean(),
      'items': Schema.list(
        items: Schema.object(
          properties: {
            'title': Schema.string(),
            'subtitle': Schema.string(),
            'icon': Schema.string(),
            'trailingText': Schema.string(),
            'event': Schema.string(),
            'destructive': Schema.boolean(),
          },
          required: ['title'],
        ),
      ),
    },
    required: ['items'],
  ),
  builder: (_, node, props, _) => ListCardWidget(
    title: props.string('title'),
    showDividers: props.boolean('showDividers') ?? true,
    items: props.objects('items'),
    dispatchEvent: (eventName) =>
        dispatchCatalogEvent(node, props, eventName, actionKey: null),
  ),
);
