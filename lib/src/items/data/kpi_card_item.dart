import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/kpi_card.dart';
import '../../utils/color_utils.dart';

final kpiCardItem = CatalogItem(
  name: 'KpiCard',
  dataSchema: S.object(
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
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final title = data['title'] as String? ?? '';
    final value = data['value'] as String? ?? '';
    final subtitle = data['subtitle'] as String?;
    final trend = data['trend'] as String?;
    final trendValue = data['trendValue'] as String?;
    final colorStr = data['color'] as String?;
    final color = (colorStr != null && colorStr.isNotEmpty)
        ? parseHexColor(colorStr)
        : null;

    return KpiCardWidget(
      key: ValueKey(itemContext.id),
      title: title,
      value: value,
      subtitle: subtitle,
      trend: trend,
      trendValue: trendValue,
      accentColor: color,
    );
  },
);
