import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/data/kpi_card_item.dart';
import 'package:genui_catalog/src/widgets/data/kpi_card.dart';
import '../../helpers.dart';

void main() {
  group('KpiCardWidget', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpWidget(wrap(
        KpiCardWidget(title: 'Revenue', value: '\$12,400'),
      ));
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('\$12,400'), findsOneWidget);
    });

    testWidgets('renders optional subtitle', (tester) async {
      await tester.pumpWidget(wrap(
        const KpiCardWidget(title: 'Users', value: '1,200', subtitle: 'vs last month'),
      ));
      expect(find.text('vs last month'), findsOneWidget);
    });

    testWidgets('renders trend value', (tester) async {
      await tester.pumpWidget(wrap(
        const KpiCardWidget(title: 'Sales', value: '500', trend: 'up', trendValue: '+8%'),
      ));
      expect(find.text('+8%'), findsOneWidget);
    });

    testWidgets('renders without trend', (tester) async {
      await tester.pumpWidget(wrap(
        const KpiCardWidget(title: 'Sales', value: '500'),
      ));
      expect(find.byType(KpiCardWidget), findsOneWidget);
    });
  });

  group('kpiCardItem', () {
    testWidgets('builds KpiCardWidget from item context', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'title': 'MRR', 'value': '\$9,800', 'trend': 'up', 'trendValue': '+12%'},
        type: 'KpiCard',
      );
      await tester.pumpWidget(wrap(kpiCardItem.widgetBuilder(ctx)));
      expect(find.byType(KpiCardWidget), findsOneWidget);
      expect(find.text('MRR'), findsOneWidget);
    });

    testWidgets('defaults gracefully with missing data', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: <String, dynamic>{},
        type: 'KpiCard',
      );
      await tester.pumpWidget(wrap(kpiCardItem.widgetBuilder(ctx)));
      expect(find.byType(KpiCardWidget), findsOneWidget);
    });
  });
}
