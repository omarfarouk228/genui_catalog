import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/form/checkbox_group_item.dart';
import 'package:genui_catalog/src/widgets/form/checkbox_group.dart';
import '../../helpers.dart';

void main() {
  group('CheckboxGroupWidget', () {
    testWidgets('renders label and options', (tester) async {
      await tester.pumpWidget(
        wrap(
          CheckboxGroupWidget(
            label: 'Preferences',
            options: const [
              {'value': 'email', 'label': 'Email notifications'},
              {'value': 'sms', 'label': 'SMS notifications'},
            ],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Email notifications'), findsOneWidget);
      expect(find.text('SMS notifications'), findsOneWidget);
    });

    testWidgets('pre-checks initial values', (tester) async {
      await tester.pumpWidget(
        wrap(
          CheckboxGroupWidget(
            options: const [
              {'value': 'a', 'label': 'A'},
              {'value': 'b', 'label': 'B'},
            ],
            initialValues: const ['a'],
            dispatchEvent: (_) {},
          ),
        ),
      );

      final checkboxes = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .toList();
      expect(checkboxes[0].value, isTrue);
      expect(checkboxes[1].value, isFalse);
    });

    testWidgets('dispatches event with selected values on toggle', (
      tester,
    ) async {
      final dispatched = <String>[];
      await tester.pumpWidget(
        wrap(
          CheckboxGroupWidget(
            event: 'prefs',
            options: const [
              {'value': 'email', 'label': 'Email'},
              {'value': 'sms', 'label': 'SMS'},
            ],
            dispatchEvent: dispatched.add,
          ),
        ),
      );

      await tester.tap(find.text('Email'));
      await tester.pump();
      expect(dispatched.last, 'prefs:email');

      await tester.tap(find.text('SMS'));
      await tester.pump();
      expect(dispatched.last, contains('sms'));
    });

    testWidgets('unchecking removes value from selection', (tester) async {
      final dispatched = <String>[];
      await tester.pumpWidget(
        wrap(
          CheckboxGroupWidget(
            event: 'prefs',
            options: const [
              {'value': 'email', 'label': 'Email'},
            ],
            initialValues: const ['email'],
            dispatchEvent: dispatched.add,
          ),
        ),
      );

      await tester.tap(find.text('Email'));
      await tester.pump();
      expect(dispatched.last, 'prefs:');
    });
  });

  group('checkboxGroupItem', () {
    testWidgets('builds with minimal data', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'options': [
            {'value': 'x', 'label': 'X'},
          ],
        },
        type: 'CheckboxGroup',
      );
      await tester.pumpWidget(wrap(checkboxGroupItem.widgetBuilder(ctx)));
      expect(find.byType(CheckboxGroupWidget), findsOneWidget);
    });
  });

  group('CheckboxGroupWidget submit mode', () {
    testWidgets('dispatches once, on submit, with the whole selection', (
      tester,
    ) async {
      final events = <String>[];
      await tester.pumpWidget(
        wrap(
          CheckboxGroupWidget(
            event: 'history',
            submitLabel: 'Valider',
            options: const [
              {'value': 'diabetes', 'label': 'Diabète'},
              {'value': 'asthma', 'label': 'Asthme'},
            ],
            dispatchEvent: events.add,
          ),
        ),
      );
      await tester.tap(find.text('Diabète'));
      await tester.tap(find.text('Asthme'));
      await tester.pump();
      expect(events, isEmpty, reason: 'toggles stay local');

      await tester.tap(find.text('Valider'));
      await tester.pump();
      expect(events, ['history:diabetes,asthma']);

      // Disabled until the selection changes again.
      await tester.tap(find.text('Valider'));
      await tester.pump();
      expect(events, hasLength(1));
    });

    testWidgets('item passes submitLabel through', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'event': 'x',
          'submitLabel': 'Send',
          'options': [
            {'value': 'a'},
          ],
        },
        type: 'CheckboxGroup',
      );
      await tester.pumpWidget(wrap(checkboxGroupItem.widgetBuilder(ctx)));
      expect(find.text('Send'), findsOneWidget);
    });
  });
}
