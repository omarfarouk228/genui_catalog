import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/chart_card.dart';

final chartCardItem = CatalogItem(
  name: 'ChartCard',
  dataSchema: S.object(
    properties: {
      'title': S.string(),
      'chartType': S.string(),
      'datasets': S.list(
        items: S.object(
          properties: {
            'label': S.string(),
            'values': S.list(items: S.number()),
            'color': S.string(),
          },
          required: ['values'],
        ),
      ),
      'xLabels': S.list(items: S.string()),
      'showLegend': S.boolean(),
    },
    required: ['title', 'chartType', 'datasets'],
  ),
  widgetBuilder: ({
    required Map<String, Object?> data,
    required String id,
    required Widget Function(Widget) buildChild,
    required Function(String event) dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final title = data['title'] as String? ?? '';
    final chartType = data['chartType'] as String? ?? 'bar';
    final showLegend = data['showLegend'] as bool? ?? false;

    final rawDatasets = data['datasets'] as List<dynamic>? ?? [];
    final datasets = rawDatasets
        .whereType<Map<String, dynamic>>()
        .take(6)
        .toList();

    final rawXLabels = data['xLabels'] as List<dynamic>?;
    final xLabels = rawXLabels?.map((e) => e.toString()).toList();

    return ChartCardWidget(
      key: ValueKey(id),
      title: title,
      chartType: chartType,
      datasets: datasets,
      xLabels: xLabels,
      showLegend: showLegend,
    );
  },
);
