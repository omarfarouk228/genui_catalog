import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/workflow/status_badge.dart';

final statusBadgeItem = CatalogItem(
  name: 'StatusBadge',
  dataSchema: S.object(
    properties: {
      'label': S.string(),
      'status': S.string(),
      'description': S.string(),
    },
    required: ['label', 'status'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final label = data['label'] as String? ?? '';
    final status = data['status'] as String? ?? 'neutral';
    final description = data['description'] as String?;

    return StatusBadgeWidget(
      key: ValueKey(itemContext.id),
      label: label,
      status: status,
      description: description,
    );
  },
);
