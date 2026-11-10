import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/workflow/status_badge.dart';

final statusBadgeItem = ComponentImplementation(
  name: 'StatusBadge',
  schema: S.object(
    properties: {
      'label': S.string(),
      'status': S.string(),
      'description': S.string(),
    },
    required: ['label', 'status'],
  ),
  builder: (context, node, props, buildChild) {
    final label = props.string('label') ?? '';
    final status = props.string('status') ?? 'neutral';
    final description = props.string('description');

    return StatusBadgeWidget(
      key: ValueKey(node.componentId),
      label: label,
      status: status,
      description: description,
    );
  },
);
