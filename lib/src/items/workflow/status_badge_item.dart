import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/workflow/status_badge.dart';

final statusBadgeItem = ComponentImplementation(
  name: 'StatusBadge',
  schema: Schema.object(
    properties: {
      'label': CatalogSchemas.text,
      'status': Schema.string(),
      'description': CatalogSchemas.text,
    },
    required: ['label', 'status'],
  ),
  builder: (_, _, props, _) => StatusBadgeWidget(
    label: props.string('label') ?? '',
    status: props.string('status') ?? 'neutral',
    description: props.string('description'),
  ),
);
