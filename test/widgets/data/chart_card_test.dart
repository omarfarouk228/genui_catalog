import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/widgets/data/chart_card.dart';
import '../../helpers.dart';

void main() {
  group('ChartCardWidget', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(wrap(
        ChartCardWidget(
          title: 'Monthly Revenue',
          chartType: 'bar',
          datasets: [
            {'label': 'Series A', 'values': [10.0, 20.0, 15.0]},
          ],
        ),
      ));
      expect(find.text('Monthly Revenue'), findsOneWidget);
    });

    testWidgets('shows truncation indicator for > 6 datasets', (tester) async {
      await tester.pumpWidget(wrap(
        ChartCardWidget(
          title: 'Chart',
          chartType: 'bar',
          datasets: List.generate(4, (i) => {'label': 'S$i', 'values': [i.toDouble()]}),
          totalDatasetCount: 9,
        ),
      ));
      expect(find.textContaining('Showing 4 of 9 datasets'), findsOneWidget);
    });

    testWidgets('does not show indicator when totalDatasetCount is null', (tester) async {
      await tester.pumpWidget(wrap(
        ChartCardWidget(
          title: 'Chart',
          chartType: 'bar',
          datasets: [{'label': 'S1', 'values': [10.0]}],
        ),
      ));
      expect(find.textContaining('Showing'), findsNothing);
    });
  });
}
