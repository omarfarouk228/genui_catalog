import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/form/switch_group_item.dart';
import 'package:genui_catalog/src/widgets/form/switch_group.dart';
import '../../helpers.dart';

void main() {
  group('SwitchGroupWidget', () {
    testWidgets('renders label and options', (tester) async {
      await tester.pumpWidget(wrap(
        SwitchGroupWidget(
          label: 'Notifications',
          options: const [
            {'value': 'push', 'label': 'Push notifications'},
            {'value': 'email', 'label': 'Email notifications'},
          ],
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Push notifications'), findsOneWidget);
      expect(find.text('Email notifications'), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(wrap(
        SwitchGroupWidget(
          options: const [
            {
              'value': 'push',
              'label': 'Push',
              'subtitle': 'Delivered to your device',
            },
          ],
          dispatchEvent: (_) {},
        ),
      ));
      expect(find.text('Delivered to your device'), findsOneWidget);
    });

    testWidgets('pre-enables initial values', (tester) async {
      await tester.pumpWidget(wrap(
        SwitchGroupWidget(
          options: const [
            {'value': 'push', 'label': 'Push'},
            {'value': 'email', 'label': 'Email'},
          ],
          initialValues: const ['push'],
          dispatchEvent: (_) {},
        ),
      ));

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isFalse);
    });

    testWidgets('dispatches on event when toggled on', (tester) async {
      final dispatched = <String>[];
      await tester.pumpWidget(wrap(
        SwitchGroupWidget(
          event: 'notify',
          options: const [
            {'value': 'push', 'label': 'Push'},
          ],
          dispatchEvent: dispatched.add,
        ),
      ));

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(dispatched, contains('notify:push:on'));
    });

    testWidgets('dispatches off event when toggled off', (tester) async {
      final dispatched = <String>[];
      await tester.pumpWidget(wrap(
        SwitchGroupWidget(
          event: 'notify',
          options: const [
            {'value': 'push', 'label': 'Push'},
          ],
          initialValues: const ['push'],
          dispatchEvent: dispatched.add,
        ),
      ));

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(dispatched, contains('notify:push:off'));
    });
  });

  group('switchGroupItem', () {
    testWidgets('builds with minimal data', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'options': [
            {'value': 'a', 'label': 'A'},
          ],
        },
        type: 'SwitchGroup',
      );
      await tester.pumpWidget(wrap(switchGroupItem.widgetBuilder(ctx)));
      expect(find.byType(SwitchGroupWidget), findsOneWidget);
    });
  });
}
