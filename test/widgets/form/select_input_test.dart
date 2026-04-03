import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/form/select_input_item.dart';
import 'package:genui_catalog/src/widgets/form/select_input.dart';
import '../../helpers.dart';

void main() {
  group('SelectInputWidget', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        wrap(
          SelectInputWidget(
            label: 'Country',
            options: const [
              {'value': 'us', 'label': 'United States'},
              {'value': 'fr', 'label': 'France'},
            ],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('renders placeholder when no initial value', (tester) async {
      await tester.pumpWidget(
        wrap(
          SelectInputWidget(
            placeholder: 'Pick one',
            options: const [
              {'value': 'a', 'label': 'Option A'},
            ],
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('Pick one'), findsOneWidget);
    });

    testWidgets('shows initial value', (tester) async {
      await tester.pumpWidget(
        wrap(
          SelectInputWidget(
            options: const [
              {'value': 'x', 'label': 'X Label'},
            ],
            initialValue: 'x',
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('X Label'), findsOneWidget);
    });

    testWidgets('dispatches event on selection', (tester) async {
      final dispatched = <String>[];
      await tester.pumpWidget(
        wrap(
          SelectInputWidget(
            event: 'country_selected',
            options: const [
              {'value': 'us', 'label': 'United States'},
              {'value': 'fr', 'label': 'France'},
            ],
            dispatchEvent: dispatched.add,
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('France').last);
      await tester.pumpAndSettle();

      expect(dispatched, contains('country_selected:fr'));
    });
  });

  group('selectInputItem', () {
    testWidgets('builds with minimal data', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'options': [
            {'value': 'a', 'label': 'A'},
          ],
        },
        type: 'SelectInput',
      );
      await tester.pumpWidget(wrap(selectInputItem.widgetBuilder(ctx)));
      expect(find.byType(SelectInputWidget), findsOneWidget);
    });
  });
}
