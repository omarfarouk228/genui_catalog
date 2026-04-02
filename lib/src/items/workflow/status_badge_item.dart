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
  widgetBuilder: ({
    required Map<String, Object?> data,
    required String id,
    required Widget Function(Widget) buildChild,
    required Function(String event) dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final label = data['label'] as String? ?? '';
    final status = data['status'] as String? ?? 'neutral';
    final description = data['description'] as String?;

    return StatusBadgeWidget(
      key: ValueKey(id),
      label: label,
      status: status,
      description: description,
    );
  },
);
