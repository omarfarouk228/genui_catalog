import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final String? title;
  final List<Map<String, dynamic>> columns;
  final List<Map<String, dynamic>> rows;
  final bool striped;
  final int? totalRowCount;

  const DataTableWidget({
    super.key,
    this.title,
    required this.columns,
    required this.rows,
    this.striped = false,
    this.totalRowCount,
  });

  @override
  Widget build(BuildContext context) {
    final isTruncated = totalRowCount != null && totalRowCount! > rows.length;

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          Semantics(
            label: title != null ? 'Table: $title' : 'Data table',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                columns: columns.map((col) {
                  final align = col['align'] as String? ?? 'left';
                  return DataColumn(
                    label: Expanded(
                      child: Text(
                        col['label'] as String? ?? col['key'] as String? ?? '',
                        textAlign: _parseTextAlign(align),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
                rows: List.generate(rows.length, (index) {
                  final row = rows[index];
                  Color? rowColor;
                  if (striped && index.isOdd) {
                    rowColor = Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow;
                  }
                  return DataRow(
                    color: rowColor != null
                        ? WidgetStateProperty.all(rowColor)
                        : null,
                    cells: columns.map((col) {
                      final key = col['key'] as String? ?? '';
                      final align = col['align'] as String? ?? 'left';
                      final cellValue = row[key];
                      return DataCell(
                        Text(
                          cellValue?.toString() ?? '',
                          textAlign: _parseTextAlign(align),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
          ),
          if (isTruncated)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'Showing ${rows.length} of $totalRowCount rows',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  TextAlign _parseTextAlign(String align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }
}
