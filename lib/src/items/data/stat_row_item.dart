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
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final rawStats = data['stats'] as List<dynamic>? ?? [];
    final stats = rawStats.whereType<Map<String, dynamic>>().toList();

    return StatRowWidget(key: ValueKey(itemContext.id), stats: stats);
  },
);
