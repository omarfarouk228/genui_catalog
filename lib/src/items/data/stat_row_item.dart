import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/data/stat_row.dart';

final statRowItem = ComponentImplementation(
  name: 'StatRow',
  schema: Schema.object(
    properties: {
      'stats': Schema.list(
        items: Schema.object(
          properties: {
            'label': Schema.string(),
            'value': Schema.string(),
            'icon': Schema.string(),
            'color': Schema.string(),
          },
          required: ['label', 'value'],
        ),
      ),
    },
    required: ['stats'],
  ),
  builder: (_, _, props, _) => StatRowWidget(stats: props.objects('stats')),
);
