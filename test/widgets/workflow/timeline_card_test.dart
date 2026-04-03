import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/workflow/timeline_card_item.dart';
import 'package:genui_catalog/src/widgets/workflow/timeline_card.dart';
import '../../helpers.dart';

void main() {
  final events = [
    {
      'time': '09:00',
      'title': 'Started',
      'description': 'Kicked off',
      'status': 'done',
    },
    {'time': '10:30', 'title': 'In Progress', 'status': 'active'},
    {'time': '12:00', 'title': 'Pending review', 'status': 'pending'},
  ];

  group('TimelineCardWidget', () {
    testWidgets('renders event titles', (tester) async {
      await tester.pumpWidget(wrap(TimelineCardWidget(events: events)));
      expect(find.text('Started'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Pending review'), findsOneWidget);
    });

    testWidgets('renders event descriptions', (tester) async {
      await tester.pumpWidget(wrap(TimelineCardWidget(events: events)));
      expect(find.text('Kicked off'), findsOneWidget);
    });

    testWidgets('renders optional title', (tester) async {
      await tester.pumpWidget(
        wrap(TimelineCardWidget(title: 'Project Timeline', events: events)),
      );
      expect(find.text('Project Timeline'), findsOneWidget);
    });

    testWidgets('renders without events', (tester) async {
      await tester.pumpWidget(wrap(const TimelineCardWidget(events: [])));
      expect(find.byType(TimelineCardWidget), findsOneWidget);
    });
  });

  group('timelineCardItem', () {
    testWidgets('builds TimelineCardWidget', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'events': events},
        type: 'TimelineCard',
      );
      await tester.pumpWidget(wrap(timelineCardItem.widgetBuilder(ctx)));
      expect(find.byType(TimelineCardWidget), findsOneWidget);
    });

    testWidgets('handles empty events list', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'events': <dynamic>[]},
        type: 'TimelineCard',
      );
      await tester.pumpWidget(wrap(timelineCardItem.widgetBuilder(ctx)));
      expect(find.byType(TimelineCardWidget), findsOneWidget);
    });
  });
}
