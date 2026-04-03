import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/data/empty_state_item.dart';
import 'package:genui_catalog/src/widgets/data/empty_state.dart';
import '../../helpers.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(wrap(
        EmptyStateWidget(
          title: 'Nothing here',
          description: 'Add something to get started.',
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Add something to get started.'), findsOneWidget);
    });

    testWidgets('renders action button and dispatches event', (tester) async {
      final dispatched = <String>[];
      await tester.pumpWidget(wrap(
        EmptyStateWidget(
          title: 'Empty',
          actionLabel: 'Add item',
          actionEvent: 'add_item',
          dispatchEvent: dispatched.add,
        ),
      ));
      expect(find.text('Add item'), findsOneWidget);
      await tester.tap(find.text('Add item'));
      await tester.pump();
      expect(dispatched, contains('add_item'));
    });

    testWidgets('no action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(wrap(
        EmptyStateWidget(
          title: 'Empty',
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('renders without any text', (tester) async {
      await tester.pumpWidget(wrap(
        EmptyStateWidget(dispatchEvent: (_) {}),
      ));
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('renders custom icon name', (tester) async {
      await tester.pumpWidget(wrap(
        EmptyStateWidget(
          iconName: 'inbox',
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.byType(Icon), findsOneWidget);
    });
  });

  group('emptyStateItem', () {
    testWidgets('builds with minimal data', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'title': 'No results'},
        type: 'EmptyState',
      );
      await tester.pumpWidget(wrap(emptyStateItem.widgetBuilder(ctx)));
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });
  });
}
