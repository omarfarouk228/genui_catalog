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
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final title = data['title'] as String? ?? '';
    final chartType = data['chartType'] as String? ?? 'bar';
    final showLegend = data['showLegend'] as bool? ?? false;

    final rawDatasets = data['datasets'] as List<dynamic>? ?? [];
    final allDatasets = rawDatasets.whereType<Map<String, dynamic>>().toList();
    const datasetLimit = 6;
    final datasets = allDatasets.take(datasetLimit).toList();

    final rawXLabels = data['xLabels'] as List<dynamic>?;
    final xLabels = rawXLabels?.map((e) => e.toString()).toList();

    return ChartCardWidget(
      key: ValueKey(itemContext.id),
      title: title,
      chartType: chartType,
      datasets: datasets,
      xLabels: xLabels,
      showLegend: showLegend,
      totalDatasetCount: allDatasets.length > datasetLimit
          ? allDatasets.length
          : null,
    );
  },
);
