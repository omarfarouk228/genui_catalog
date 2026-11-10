import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/data/flex_layout_item.dart';
import 'package:genui_catalog/src/items/workflow/status_badge_item.dart';
import 'package:genui_catalog/src/widgets/workflow/status_badge.dart';
import '../../helpers.dart';

void main() {
  final badges = [
    {
      'id': 'first',
      'component': 'StatusBadge',
      'label': 'First',
      'status': 'success',
    },
    {
      'id': 'second',
      'component': 'StatusBadge',
      'label': 'Second',
      'status': 'info',
    },
  ];

  group('columnItem', () {
    testWidgets('renders its children in order', (tester) async {
      await pumpComponents(
        tester,
        [columnItem, statusBadgeItem],
        [
          {
            'id': 'root',
            'component': 'Column',
            'children': ['first', 'second'],
            'spacing': 8,
          },
          ...badges,
        ],
      );
      expect(find.byType(StatusBadgeWidget), findsNWidgets(2));
      expect(
        tester.getTopLeft(find.text('First')).dy,
        lessThan(tester.getTopLeft(find.text('Second')).dy),
      );
    });
  });

  group('rowItem', () {
    testWidgets('renders its children', (tester) async {
      await pumpComponents(
        tester,
        [rowItem, statusBadgeItem],
        [
          {
            'id': 'root',
            'component': 'Row',
            'children': ['first', 'second'],
          },
          ...badges,
        ],
      );
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });
  });
}
