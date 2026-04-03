import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/data_table_widget.dart';

final dataTableItem = CatalogItem(
  name: 'DataTable',
  dataSchema: S.object(
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
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final title = data['title'] as String?;
    final striped = data['striped'] as bool? ?? false;

    final rawColumns = data['columns'] as List<dynamic>? ?? [];
    final columns = rawColumns.whereType<Map<String, dynamic>>().toList();

    final rawRows = data['rows'] as List<dynamic>? ?? [];
    final rows = rawRows.whereType<Map<String, dynamic>>().take(100).toList();

    return DataTableWidget(
      key: ValueKey(itemContext.id),
      title: title,
      columns: columns,
      rows: rows,
      striped: striped,
    );
  },
);
