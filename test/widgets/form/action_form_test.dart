import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:genui_catalog/src/items/form/action_form_item.dart';
import 'package:genui_catalog/src/widgets/form/action_form.dart';
import '../../helpers.dart';

void main() {
  group('ActionFormWidget', () {
    testWidgets('renders form fields and submit button', (tester) async {
      await tester.pumpWidget(
        wrap(
          ActionFormWidget(
            fields: [
              {
                'key': 'name',
                'label': 'Full Name',
                'type': 'text',
                'required': false,
              },
            ],
            submitLabel: 'Submit',
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows validation error when required field is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ActionFormWidget(
            fields: [
              {
                'key': 'email',
                'label': 'Email',
                'type': 'email',
                'required': true,
              },
            ],
            submitLabel: 'Go',
            dispatchEvent: (_) {},
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.textContaining('required'), findsOneWidget);
    });

    testWidgets('shows success message after submit', (tester) async {
      await tester.pumpWidget(
        wrap(
          ActionFormWidget(
            fields: [
              {'key': 'name', 'label': 'Name', 'required': false},
            ],
            submitLabel: 'OK',
            successMessage: 'Saved!',
            dispatchEvent: (_) {},
          ),
        ),
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Saved!'), findsOneWidget);
    });
  });

  group('actionFormItem', () {
    testWidgets('dispatches UserActionEvent on valid submit', (tester) async {
      final events = <UiEvent>[];
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'fields': [
            {'key': 'name', 'label': 'Name', 'type': 'text', 'required': true},
          ],
          'submitLabel': 'Send',
        },
        onDispatch: events.add,
      );
      await tester.pumpWidget(wrap(actionFormItem.widgetBuilder(ctx)));
      await tester.enterText(find.byType(TextFormField), 'Bob');
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(events, isNotEmpty);
      expect(events.first, isA<UserActionEvent>());
      expect((events.first as UserActionEvent).name, equals('form_submit'));
    });
  });
}
