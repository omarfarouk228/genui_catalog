import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../widgets/data/data_table_widget.dart';

const _rowLimit = 100;

final dataTableItem = ComponentImplementation(
  name: 'DataTable',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'columns': Schema.list(
        items: Schema.object(
          properties: {
            'key': Schema.string(),
            'label': Schema.string(),
            'align': Schema.string(),
          },
          required: ['key', 'label'],
        ),
      ),
      'rows': Schema.list(items: Schema.object(properties: {})),
      'striped': Schema.boolean(),
    },
    required: ['columns', 'rows'],
  ),
  builder: (_, _, props, _) {
    final allRows = props.objects('rows');
    return DataTableWidget(
      title: props.string('title'),
      columns: props.objects('columns'),
      rows: allRows.take(_rowLimit).toList(),
      striped: props.boolean('striped') ?? false,
      totalRowCount: allRows.length > _rowLimit ? allRows.length : null,
    );
  },
);
