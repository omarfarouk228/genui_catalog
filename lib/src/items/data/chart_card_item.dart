import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/chart_card.dart';

final chartCardItem = ComponentImplementation(
  name: 'ChartCard',
  schema: S.object(
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
  builder: (context, node, props, buildChild) {
    final title = props.string('title') ?? '';
    final chartType = props.string('chartType') ?? 'bar';
    final showLegend = props.boolean('showLegend') ?? false;

    final rawDatasets = props.list('datasets');
    final allDatasets = rawDatasets.whereType<Map<String, dynamic>>().toList();
    const datasetLimit = 6;
    final datasets = allDatasets.take(datasetLimit).toList();

    final rawXLabels = props.value('xLabels') as List<dynamic>?;
    final xLabels = rawXLabels?.map((e) => e.toString()).toList();

    return ChartCardWidget(
      key: ValueKey(node.componentId),
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
