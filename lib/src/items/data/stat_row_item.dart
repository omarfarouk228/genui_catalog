import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/stat_row.dart';

final statRowItem = ComponentImplementation(
  name: 'StatRow',
  schema: S.object(
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
  builder: (context, node, props, buildChild) {
    final rawStats = props.list('stats');
    final stats = rawStats.whereType<Map<String, dynamic>>().toList();

    return StatRowWidget(key: ValueKey(node.componentId), stats: stats);
  },
);
