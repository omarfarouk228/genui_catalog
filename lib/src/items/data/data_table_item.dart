import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/data_table_widget.dart';

final dataTableItem = ComponentImplementation(
  name: 'DataTable',
  schema: S.object(
    properties: {
      'title': S.string(),
      'columns': S.list(
        items: S.object(
          properties: {
            'key': S.string(),
            'label': S.string(),
            'align': S.string(),
          },
          required: ['key', 'label'],
        ),
      ),
      'rows': S.list(items: S.object(properties: {})),
      'striped': S.boolean(),
    },
    required: ['columns', 'rows'],
  ),
  builder: (context, node, props, buildChild) {
    final title = props.string('title');
    final striped = props.boolean('striped') ?? false;

    final rawColumns = props.list('columns');
    final columns = rawColumns.whereType<Map<String, dynamic>>().toList();

    final rawRows = props.list('rows');
    final allRows = rawRows.whereType<Map<String, dynamic>>().toList();
    const rowLimit = 100;
    final rows = allRows.take(rowLimit).toList();

    return DataTableWidget(
      key: ValueKey(node.componentId),
      title: title,
      columns: columns,
      rows: rows,
      striped: striped,
      totalRowCount: allRows.length > rowLimit ? allRows.length : null,
    );
  },
);
