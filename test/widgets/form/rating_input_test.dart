import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:genui_catalog/src/items/form/rating_input_item.dart';
import 'package:genui_catalog/src/widgets/form/rating_input.dart';
import '../../helpers.dart';

void main() {
  group('RatingInputWidget', () {
    testWidgets('renders correct number of stars', (tester) async {
      await tester.pumpWidget(
        wrap(
          RatingInputWidget(
            maxStars: 5,
            allowHalf: false,
            dispatchEvent: (_, _) {},
          ),
        ),
      );
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    });

    testWidgets('dispatches event on star tap', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        wrap(
          RatingInputWidget(
            maxStars: 5,
            allowHalf: false,
            dispatchEvent: (e, _) => events.add(e),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pump();
      expect(events, contains('rating_submitted'));
    });

    testWidgets('shows rating value after selection', (tester) async {
      await tester.pumpWidget(
        wrap(
          RatingInputWidget(
            maxStars: 5,
            allowHalf: false,
            dispatchEvent: (_, _) {},
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.star_border).at(2));
      await tester.pump();
      expect(find.textContaining('/ 5'), findsOneWidget);
    });

    testWidgets('renders label when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          RatingInputWidget(
            maxStars: 5,
            allowHalf: false,
            label: 'Rate your experience',
            dispatchEvent: (_, _) {},
          ),
        ),
      );
      expect(find.text('Rate your experience'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          RatingInputWidget(
            title: 'Feedback',
            maxStars: 5,
            allowHalf: false,
            dispatchEvent: (_, _) {},
          ),
        ),
      );
      expect(find.text('Feedback'), findsOneWidget);
    });
  });

  group('ratingInputItem', () {
    testWidgets('builds RatingInputWidget', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'maxStars': 5, 'allowHalf': false},
        type: 'RatingInput',
      );
      await tester.pumpWidget(wrap(ratingInputItem.widgetBuilder(ctx)));
      expect(find.byType(RatingInputWidget), findsOneWidget);
    });
  });

  group('RatingInputWidget rating value', () {
    testWidgets('dispatches the selected rating and maxStars', (tester) async {
      final sent = <(String, Map<String, Object>)>[];
      await tester.pumpWidget(
        wrap(
          RatingInputWidget(
            maxStars: 5,
            allowHalf: false,
            dispatchEvent: (e, c) => sent.add((e, c)),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.star_border).at(3));
      await tester.pump();
      expect(sent.single.$1, 'rating_submitted');
      expect(sent.single.$2, {'rating': 4, 'maxStars': 5});
    });

    testWidgets('item forwards the rating in the event context', (
      tester,
    ) async {
      final events = <UiEvent>[];
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'maxStars': 5, 'allowHalf': false},
        type: 'RatingInput',
        onDispatch: events.add,
      );
      await tester.pumpWidget(wrap(ratingInputItem.widgetBuilder(ctx)));
      await tester.tap(find.byIcon(Icons.star_border).at(1));
      await tester.pump();
      final event = events.single as UserActionEvent;
      expect(event.name, 'rating_submitted');
      expect(event.context, {'rating': 2, 'maxStars': 5});
    });

    testWidgets('uses translated screen-reader labels', (tester) async {
      await tester.pumpWidget(
        wrap(
          RatingInputWidget(
            maxStars: 5,
            allowHalf: false,
            noRatingLabel: 'Aucune note',
            outOfLabel: 'sur',
            dispatchEvent: (_, _) {},
          ),
        ),
      );
      final handle = tester.ensureSemantics();
      expect(tester.getSemantics(find.byType(Row).first).value, 'Aucune note');
      await tester.tap(find.byIcon(Icons.star_border).at(2));
      await tester.pump();
      expect(tester.getSemantics(find.byType(Row).first).value, '3.0 sur 5');
      handle.dispose();
    });
  });
}
