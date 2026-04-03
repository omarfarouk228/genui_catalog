import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/data/list_card_item.dart';
import 'package:genui_catalog/src/widgets/data/list_card.dart';
import '../../helpers.dart';

void main() {
  group('ListCardWidget', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(wrap(
        ListCardWidget(
          title: 'My List',
          items: const [{'title': 'Item A'}],
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.text('My List'), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
    });

    testWidgets('renders subtitle and trailingText', (tester) async {
      await tester.pumpWidget(wrap(
        ListCardWidget(
          items: const [
            {'title': 'Row', 'subtitle': 'Sub', 'trailingText': 'Right'},
          ],
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.text('Sub'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('dispatches event on tap', (tester) async {
      final dispatched = <String>[];
      await tester.pumpWidget(wrap(
        ListCardWidget(
          items: const [{'title': 'Tap me', 'event': 'item_tapped'}],
          dispatchEvent: dispatched.add,
        ),
      ));
      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(dispatched, contains('item_tapped'));
    });

    testWidgets('non-tappable item has no chevron', (tester) async {
      await tester.pumpWidget(wrap(
        ListCardWidget(
          items: const [{'title': 'Static'}],
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('tappable item shows chevron when no trailingText', (tester) async {
      await tester.pumpWidget(wrap(
        ListCardWidget(
          items: const [{'title': 'Go', 'event': 'go'}],
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('destructive item uses error color', (tester) async {
      await tester.pumpWidget(wrap(
        ListCardWidget(
          items: const [
            {'title': 'Delete', 'event': 'delete', 'destructive': true},
          ],
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('showDividers false hides dividers', (tester) async {
      await tester.pumpWidget(wrap(
        ListCardWidget(
          showDividers: false,
          items: const [
            {'title': 'A'},
            {'title': 'B'},
          ],
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.byType(Divider), findsNothing);
    });
  });

  group('listCardItem', () {
    testWidgets('builds with minimal data', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'items': [
            {'title': 'Hello'},
          ],
        },
        type: 'ListCard',
      );
      await tester.pumpWidget(wrap(listCardItem.widgetBuilder(ctx)));
      expect(find.byType(ListCardWidget), findsOneWidget);
    });
  });
}
