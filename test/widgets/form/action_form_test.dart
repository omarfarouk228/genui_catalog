import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
            dispatchEvent: (_, _) {},
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
            dispatchEvent: (_, _) {},
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
            dispatchEvent: (_, _) {},
          ),
        ),
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Saved!'), findsOneWidget);
    });
  });

  group('actionFormItem', () {
    testWidgets('dispatches an action on valid submit', (tester) async {
      final harness = await pumpItem(
        tester,
        actionFormItem,
        data: {
          'fields': [
            {'key': 'name', 'label': 'Name', 'type': 'text', 'required': true},
          ],
          'submitLabel': 'Send',
        },
      );
      await tester.enterText(find.byType(TextFormField), 'Bob');
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      final events = harness.actions;
      expect(events, isNotEmpty);
      expect(events.first.name, equals('form_submit'));
      expect(events.first.context, {'name': 'Bob'});
    });
  });

  group('ActionFormWidget translations', () {
    testWidgets('uses requiredErrorText with the field label', (tester) async {
      await tester.pumpWidget(
        wrap(
          ActionFormWidget(
            fields: const [
              {'key': 'name', 'label': 'Prénom', 'required': true},
            ],
            submitLabel: 'Envoyer',
            requiredErrorText: '{label} est obligatoire',
            dispatchEvent: (_, _) {},
          ),
        ),
      );
      await tester.tap(find.text('Envoyer'));
      await tester.pump();
      expect(find.text('Prénom est obligatoire'), findsOneWidget);
    });
  });
}
