import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../catalog_events.dart';
import '../../widgets/data/empty_state.dart';

/// The button sends `actionEvent`, or runs `action` when the agent declares
/// one.
final emptyStateItem = ComponentImplementation(
  name: 'EmptyState',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'description': CatalogSchemas.text,
      'icon': Schema.string(),
      'actionLabel': CatalogSchemas.text,
      'actionEvent': Schema.string(),
      'action': CatalogSchemas.action,
    },
  ),
  builder: (_, node, props, _) => EmptyStateWidget(
    title: props.string('title'),
    description: props.string('description'),
    iconName: props.string('icon'),
    actionLabel: props.string('actionLabel'),
    actionEvent:
        props.string('actionEvent') ??
        (props.action('action') != null
            ? CatalogEvents.emptyStateAction
            : null),
    dispatchEvent: (eventName) => dispatchCatalogEvent(node, props, eventName),
  ),
);
