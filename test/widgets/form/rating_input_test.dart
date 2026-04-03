import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
            dispatchEvent: (_) {},
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
            dispatchEvent: events.add,
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
            dispatchEvent: (_) {},
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
            dispatchEvent: (_) {},
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
            dispatchEvent: (_) {},
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
}
