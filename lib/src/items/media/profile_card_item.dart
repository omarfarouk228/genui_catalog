import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/media/profile_card.dart';

/// Each action button sends its `event` as-is.
final profileCardItem = ComponentImplementation(
  name: 'ProfileCard',
  schema: Schema.object(
    properties: {
      'name': CatalogSchemas.text,
      'role': CatalogSchemas.text,
      'avatarUrl': CatalogSchemas.text,
      'details': Schema.list(
        items: Schema.object(
          properties: {'label': Schema.string(), 'value': Schema.string()},
          required: ['label', 'value'],
        ),
      ),
      'actions': Schema.list(
        items: Schema.object(
          properties: {'label': Schema.string(), 'event': Schema.string()},
          required: ['label', 'event'],
        ),
      ),
    },
    required: ['name'],
  ),
  builder: (_, node, props, _) => ProfileCardWidget(
    name: props.string('name') ?? '',
    role: props.string('role'),
    avatarUrl: props.string('avatarUrl'),
    details: props.objects('details'),
    actions: props.objects('actions'),
    dispatchEvent: (eventName) =>
        dispatchCatalogEvent(node, props, eventName, actionKey: null),
  ),
);
