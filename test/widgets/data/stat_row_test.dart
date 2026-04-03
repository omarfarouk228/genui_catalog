import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/data/stat_row_item.dart';
import 'package:genui_catalog/src/widgets/data/stat_row.dart';
import '../../helpers.dart';

void main() {
  group('StatRowWidget', () {
    testWidgets('renders all stats', (tester) async {
      await tester.pumpWidget(wrap(
        StatRowWidget(stats: [
          {'label': 'Users', 'value': '100'},
          {'label': 'Orders', 'value': '50'},
        ]),
      ));
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('handles empty list', (tester) async {
      await tester.pumpWidget(wrap(StatRowWidget(stats: const [])));
      expect(find.byType(StatRowWidget), findsOneWidget);
    });
  });

  group('statRowItem', () {
    testWidgets('builds StatRowWidget', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'stats': [
            {'label': 'A', 'value': '1'},
            {'label': 'B', 'value': '2'},
          ],
        },
        type: 'StatRow',
      );
      await tester.pumpWidget(wrap(statRowItem.widgetBuilder(ctx)));
      expect(find.byType(StatRowWidget), findsOneWidget);
    });
  });
}
