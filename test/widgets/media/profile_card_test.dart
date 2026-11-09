import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/media/profile_card_item.dart';
import 'package:genui_catalog/src/widgets/media/profile_card.dart';
import '../../helpers.dart';

void main() {
  group('ProfileCardWidget', () {
    testWidgets('renders name and role', (tester) async {
      await tester.pumpWidget(
        wrap(
          ProfileCardWidget(
            name: 'Alice Martin',
            role: 'Engineer',
            details: const [],
            actions: const [],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('Alice Martin'), findsOneWidget);
      expect(find.text('Engineer'), findsOneWidget);
    });

    testWidgets('renders details', (tester) async {
      await tester.pumpWidget(
        wrap(
          ProfileCardWidget(
            name: 'Bob',
            details: [
              {'label': 'Team', 'value': 'Platform'},
              {'label': 'Location', 'value': 'Paris'},
            ],
            actions: const [],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('Team'), findsOneWidget);
      expect(find.text('Platform'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('dispatches action events', (tester) async {
      final dispatched = <String>[];
      await tester.pumpWidget(
        wrap(
          ProfileCardWidget(
            name: 'Carol',
            details: const [],
            actions: [
              {'label': 'Message', 'event': 'message_user'},
            ],
            dispatchEvent: dispatched.add,
          ),
        ),
      );
      await tester.tap(find.text('Message'));
      await tester.pump();
      expect(dispatched, contains('message_user'));
    });

    testWidgets('shows initials when no avatar url', (tester) async {
      await tester.pumpWidget(
        wrap(
          ProfileCardWidget(
            name: 'John Doe',
            details: const [],
            actions: const [],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('JD'), findsOneWidget);
    });
  });

  group('profileCardItem', () {
    testWidgets('builds with minimal data', (tester) async {
      await pumpItem(tester, profileCardItem, data: {'name': 'Eve'});
      expect(find.byType(ProfileCardWidget), findsOneWidget);
    });

    testWidgets('dispatches the event of an action button', (tester) async {
      final harness = await pumpItem(
        tester,
        profileCardItem,
        data: {
          'name': 'Eve',
          'actions': [
            {'label': 'Message', 'event': 'profile_message'},
          ],
        },
      );
      await tester.tap(find.text('Message'));
      await tester.pump();
      expect(harness.actions.single.name, 'profile_message');
    });
  });
}
