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
}
