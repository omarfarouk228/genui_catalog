import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/form/rating_input_item.dart';
import 'package:genui_catalog/src/widgets/form/rating_input.dart';
import '../../a2ui_harness.dart';

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

  group('RatingInputWidget controlled rating', () {
    testWidgets('starts from and follows the given rating', (tester) async {
      Widget build(double rating) => wrap(
        RatingInputWidget(
          maxStars: 5,
          allowHalf: false,
          rating: rating,
          dispatchEvent: (_, _) {},
        ),
      );
      await tester.pumpWidget(build(2));
      expect(find.byIcon(Icons.star), findsNWidgets(2));
      await tester.pumpWidget(build(4));
      expect(find.byIcon(Icons.star), findsNWidgets(4));
    });
  });

  group('ratingInputItem (A2UI)', () {
    final catalog = testCatalog([ratingInputItem]);

    testWidgets('renders literal properties', (tester) async {
      final harness = await A2uiHarness.pump(
        tester,
        catalog: catalog,
        components: [
          {
            'id': 'root',
            'component': 'RatingInput',
            'title': 'Feedback',
            'maxStars': 4,
            'value': 1,
          },
        ],
      );
      expect(find.text('Feedback'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNWidgets(3));
      expect(harness.errors, isEmpty);
    });

    testWidgets('writes the rating to the bound path and runs the action', (
      tester,
    ) async {
      final harness = await A2uiHarness.pump(
        tester,
        catalog: catalog,
        dataModel: {'rating': 1},
        components: [
          {
            'id': 'root',
            'component': 'RatingInput',
            'maxStars': 5,
            'value': {'@path': '/rating'},
            'action': {
              'event': {
                'name': 'rating_submitted',
                'context': {
                  'rating': {'@path': '/rating'},
                },
              },
            },
          },
        ],
      );
      expect(find.byIcon(Icons.star), findsOneWidget);

      await tester.tap(find.byIcon(Icons.star_border).at(2)); // 4th star
      await tester.pump();

      expect(harness.data('/rating'), 4);
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      final action = harness.actions.single;
      expect(action.name, 'rating_submitted');
      expect(action.context, {'rating': 4});
      expect(action.metadata, {
        'extensions': {
          'genui_catalog': {'rating': 4, 'maxStars': 5},
        },
      });
      expect(harness.errors, isEmpty);
    });

    testWidgets('follows data model updates from the agent', (tester) async {
      final harness = await A2uiHarness.pump(
        tester,
        catalog: catalog,
        dataModel: {'rating': 1},
        components: [
          {
            'id': 'root',
            'component': 'RatingInput',
            'value': {'@path': '/rating'},
          },
        ],
      );
      harness.processor.processMessages([
        {
          'version': '1.0',
          'updateDataModel': {
            'surfaceId': testSurfaceId,
            'path': '/rating',
            'value': 3,
          },
        },
      ]);
      await tester.pump();
      expect(find.byIcon(Icons.star), findsNWidgets(3));
    });

    testWidgets('without a binding, still sends the rating as metadata', (
      tester,
    ) async {
      final harness = await A2uiHarness.pump(
        tester,
        catalog: catalog,
        components: [
          {
            'id': 'root',
            'component': 'RatingInput',
            'action': {
              'event': {'name': 'rated'},
            },
          },
        ],
      );
      await tester.tap(find.byIcon(Icons.star_border).at(1));
      await tester.pump();
      expect(find.byIcon(Icons.star), findsNWidgets(2));
      expect(harness.actions.single.metadata, {
        'extensions': {
          'genui_catalog': {'rating': 2, 'maxStars': 5},
        },
      });
    });
  });
}
