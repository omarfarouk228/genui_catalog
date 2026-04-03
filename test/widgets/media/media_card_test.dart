import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/media/media_card_item.dart';
import 'package:genui_catalog/src/widgets/media/media_card.dart';
import '../../helpers.dart';

void main() {
  group('MediaCardWidget', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(
        wrap(
          MediaCardWidget(
            title: 'My Article',
            content: 'Some interesting content',
            tags: const [],
            actions: const [],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('My Article'), findsOneWidget);
      expect(find.text('Some interesting content'), findsOneWidget);
    });

    testWidgets('renders tags as chips', (tester) async {
      await tester.pumpWidget(
        wrap(
          MediaCardWidget(
            title: 'Article',
            tags: const ['flutter', 'dart'],
            actions: const [],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
    });

    testWidgets('dispatches action events', (tester) async {
      final dispatched = <String>[];
      await tester.pumpWidget(
        wrap(
          MediaCardWidget(
            title: 'Article',
            tags: const [],
            actions: [
              {'label': 'Read more', 'event': 'read'},
            ],
            dispatchEvent: dispatched.add,
          ),
        ),
      );
      await tester.tap(find.text('Read more'));
      await tester.pump();
      expect(dispatched, contains('read'));
    });

    testWidgets('renders without optional content', (tester) async {
      await tester.pumpWidget(
        wrap(
          MediaCardWidget(
            title: 'Minimal',
            tags: const [],
            actions: const [],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.byType(MediaCardWidget), findsOneWidget);
    });
  });

  group('mediaCardItem', () {
    testWidgets('builds with minimal data', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'title': 'Post'},
        type: 'MediaCard',
      );
      await tester.pumpWidget(wrap(mediaCardItem.widgetBuilder(ctx)));
      expect(find.byType(MediaCardWidget), findsOneWidget);
    });
  });
}
