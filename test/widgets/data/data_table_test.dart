import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/data/data_table_item.dart';
import 'package:genui_catalog/src/widgets/data/data_table_widget.dart';
import '../../helpers.dart';

void main() {
  final columns = [
    {'key': 'name', 'label': 'Name'},
    {'key': 'age', 'label': 'Age'},
  ];

  group('DataTableWidget', () {
    testWidgets('renders column headers and rows', (tester) async {
      await tester.pumpWidget(
        wrap(
          DataTableWidget(
            columns: columns,
            rows: [
              {'name': 'Alice', 'age': '30'},
              {'name': 'Bob', 'age': '25'},
            ],
          ),
        ),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows truncation indicator when totalRowCount > rows.length', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          DataTableWidget(
            columns: columns,
            rows: [
              {'name': 'Alice', 'age': '30'},
            ],
            totalRowCount: 150,
          ),
        ),
      );
      expect(find.textContaining('Showing 1 of 150 rows'), findsOneWidget);
    });

    testWidgets(
      'does not show truncation indicator when totalRowCount is null',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            DataTableWidget(
              columns: columns,
              rows: [
                {'name': 'Alice', 'age': '30'},
              ],
            ),
          ),
        );
        expect(find.textContaining('Showing'), findsNothing);
      },
    );

    testWidgets('renders with empty rows', (tester) async {
      await tester.pumpWidget(
        wrap(DataTableWidget(columns: columns, rows: const [])),
      );
      expect(find.byType(DataTableWidget), findsOneWidget);
    });

    testWidgets('renders with title', (tester) async {
      await tester.pumpWidget(
        wrap(
          DataTableWidget(title: 'Orders', columns: columns, rows: const []),
        ),
      );
      expect(find.text('Orders'), findsOneWidget);
    });
  });

  group('dataTableItem truncation', () {
    testWidgets('shows indicator for > 100 rows', (tester) async {
      final manyRows = List.generate(
        120,
        (i) => {'name': 'User $i', 'age': '$i'},
      );
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'columns': [
            {'key': 'name', 'label': 'Name'},
          ],
          'rows': manyRows,
        },
        type: 'DataTable',
      );
      await tester.pumpWidget(wrap(dataTableItem.widgetBuilder(ctx)));
      expect(find.textContaining('Showing 100 of 120 rows'), findsOneWidget);
    });

    testWidgets('does not show indicator when rows <= 100', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'columns': [
            {'key': 'name', 'label': 'Name'},
          ],
          'rows': [
            {'name': 'Alice'},
          ],
        },
        type: 'DataTable',
      );
      await tester.pumpWidget(wrap(dataTableItem.widgetBuilder(ctx)));
      expect(find.textContaining('Showing'), findsNothing);
    });
  });
}
