import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/kpi_card.dart';
import '../../utils/color_utils.dart';

final kpiCardItem = ComponentImplementation(
  name: 'KpiCard',
  schema: S.object(
    properties: {
      'title': S.string(),
      'value': S.string(),
      'subtitle': S.string(),
      'trend': S.string(),
      'trendValue': S.string(),
      'color': S.string(),
    },
    required: ['title', 'value'],
  ),
  builder: (context, node, props, buildChild) {
    final title = props.string('title') ?? '';
    final value = props.string('value') ?? '';
    final subtitle = props.string('subtitle');
    final trend = props.string('trend');
    final trendValue = props.string('trendValue');
    final colorStr = props.string('color');
    final color = (colorStr != null && colorStr.isNotEmpty)
        ? parseHexColor(colorStr)
        : null;

    return KpiCardWidget(
      key: ValueKey(node.componentId),
      title: title,
      value: value,
      subtitle: subtitle,
      trend: trend,
      trendValue: trendValue,
      accentColor: color,
    );
  },
);
