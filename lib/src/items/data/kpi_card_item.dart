import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../utils/color_utils.dart';
import '../../widgets/data/kpi_card.dart';

final kpiCardItem = ComponentImplementation(
  name: 'KpiCard',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'value': CatalogSchemas.text,
      'subtitle': CatalogSchemas.text,
      'trend': Schema.string(),
      'trendValue': CatalogSchemas.text,
      'color': Schema.string(),
    },
    required: ['title', 'value'],
  ),
  builder: (_, _, props, _) {
    final colorStr = props.string('color');
    return KpiCardWidget(
      title: props.string('title') ?? '',
      value: props.string('value') ?? '',
      subtitle: props.string('subtitle'),
      trend: props.string('trend'),
      trendValue: props.string('trendValue'),
      accentColor: (colorStr != null && colorStr.isNotEmpty)
          ? parseHexColor(colorStr)
          : null,
    );
  },
);
