import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/stat_row.dart';

final statRowItem = CatalogItem(
  name: 'StatRow',
  dataSchema: S.object(
    properties: {
      'stats': S.list(
        items: S.object(
          properties: {
            'label': S.string(),
            'value': S.string(),
            'icon': S.string(),
            'color': S.string(),
          },
          required: ['label', 'value'],
        ),
      ),
    },
    required: ['stats'],
  ),
  widgetBuilder: ({
    required Map<String, Object?> data,
    required String id,
    required Widget Function(Widget) buildChild,
    required Function(String event) dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final rawStats = data['stats'] as List<dynamic>? ?? [];
    final stats = rawStats
        .whereType<Map<String, dynamic>>()
        .take(4)
        .toList();

    return StatRowWidget(
      key: ValueKey(id),
      stats: stats,
    );
  },
);
