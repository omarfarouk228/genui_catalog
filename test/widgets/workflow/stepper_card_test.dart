import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/workflow/stepper_card_item.dart';
import 'package:genui_catalog/src/widgets/workflow/stepper_card.dart';
import '../../helpers.dart';

void main() {
  final steps = [
    {'title': 'Step One', 'description': 'Do this first'},
    {'title': 'Step Two', 'description': 'Then this'},
    {'title': 'Step Three', 'description': 'Finally this'},
  ];

  group('StepperCardWidget', () {
    testWidgets('renders current step content', (tester) async {
      await tester.pumpWidget(
        wrap(
          StepperCardWidget(
            steps: steps,
            initialStep: 0,
            showNavigation: true,
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('Step One'), findsOneWidget);
      expect(find.text('Do this first'), findsOneWidget);
    });

    testWidgets('navigates to next step', (tester) async {
      await tester.pumpWidget(
        wrap(
          StepperCardWidget(
            steps: steps,
            initialStep: 0,
            showNavigation: true,
            dispatchEvent: (_) {},
          ),
        ),
      );
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Step Two'), findsOneWidget);
    });

    testWidgets('dispatches next_step event', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        wrap(
          StepperCardWidget(
            steps: steps,
            initialStep: 0,
            showNavigation: true,
            dispatchEvent: events.add,
          ),
        ),
      );
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(events, contains('next_step'));
    });

    testWidgets('Previous button disabled on first step', (tester) async {
      await tester.pumpWidget(
        wrap(
          StepperCardWidget(
            steps: steps,
            initialStep: 0,
            showNavigation: true,
            dispatchEvent: (_) {},
          ),
        ),
      );
      final prevButton = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Previous'),
          matching: find.byType(TextButton),
        ),
      );
      expect(prevButton.onPressed, isNull);
    });

    testWidgets('renders without navigation buttons', (tester) async {
      await tester.pumpWidget(
        wrap(
          StepperCardWidget(
            steps: steps,
            initialStep: 1,
            showNavigation: false,
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('Next'), findsNothing);
      expect(find.text('Step Two'), findsOneWidget);
    });
  });

  group('stepperCardItem', () {
    testWidgets('builds StepperCardWidget', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {
          'steps': [
            {'title': 'A', 'description': 'step a'},
            {'title': 'B', 'description': 'step b'},
          ],
          'initialStep': 0,
          'showNavigation': false,
        },
        type: 'StepperCard',
      );
      await tester.pumpWidget(wrap(stepperCardItem.widgetBuilder(ctx)));
      expect(find.byType(StepperCardWidget), findsOneWidget);
    });
  });

  group('StepperCardWidget 0.5.0', () {
    testWidgets('uses translated navigation labels', (tester) async {
      await tester.pumpWidget(
        wrap(
          StepperCardWidget(
            steps: steps,
            initialStep: 0,
            showNavigation: true,
            previousLabel: 'Précédent',
            nextLabel: 'Suivant',
            dispatchEvent: (_) {},
          ),
        ),
      );
      expect(find.text('Précédent'), findsOneWidget);
      expect(find.text('Suivant'), findsOneWidget);
    });

    testWidgets('tapping a step shows it without dispatching', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        wrap(
          StepperCardWidget(
            steps: steps,
            initialStep: 0,
            showNavigation: false,
            dispatchEvent: events.add,
          ),
        ),
      );
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(find.text('Finally this'), findsOneWidget);
      expect(events, isEmpty);
    });
  });
}
