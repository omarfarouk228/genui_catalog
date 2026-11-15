import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/data/chart_card.dart';

const _datasetLimit = 6;

final chartCardItem = ComponentImplementation(
  name: 'ChartCard',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'chartType': Schema.string(),
      'datasets': Schema.list(
        items: Schema.object(
          properties: {
            'label': Schema.string(),
            'values': Schema.list(items: Schema.number()),
            'color': Schema.string(),
          },
          required: ['values'],
        ),
      ),
      'xLabels': Schema.list(items: Schema.string()),
      'showLegend': Schema.boolean(),
    },
    required: ['title', 'chartType', 'datasets'],
  ),
  builder: (_, _, props, _) {
    final allDatasets = props.objects('datasets');
    final xLabels = props.strings('xLabels');
    return ChartCardWidget(
      title: props.string('title') ?? '',
      chartType: props.string('chartType') ?? 'bar',
      datasets: allDatasets.take(_datasetLimit).toList(),
      xLabels: xLabels.isEmpty ? null : xLabels,
      showLegend: props.boolean('showLegend') ?? false,
      totalDatasetCount: allDatasets.length > _datasetLimit
          ? allDatasets.length
          : null,
    );
  },
);
