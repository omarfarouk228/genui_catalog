import 'package:a2ui_core/a2ui_core.dart' show A2uiValidationError;
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/data/kpi_card_item.dart';
import 'package:genui_catalog/src/widgets/data/kpi_card.dart';
import '../../helpers.dart';

void main() {
  group('KpiCardWidget', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpWidget(
        wrap(KpiCardWidget(title: 'Revenue', value: '\$12,400')),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('\$12,400'), findsOneWidget);
    });

    testWidgets('renders optional subtitle', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KpiCardWidget(
            title: 'Users',
            value: '1,200',
            subtitle: 'vs last month',
          ),
        ),
      );
      expect(find.text('vs last month'), findsOneWidget);
    });

    testWidgets('renders trend value', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KpiCardWidget(
            title: 'Sales',
            value: '500',
            trend: 'up',
            trendValue: '+8%',
          ),
        ),
      );
      expect(find.text('+8%'), findsOneWidget);
    });

    testWidgets('renders without trend', (tester) async {
      await tester.pumpWidget(
        wrap(const KpiCardWidget(title: 'Sales', value: '500')),
      );
      expect(find.byType(KpiCardWidget), findsOneWidget);
    });
  });

  group('kpiCardItem', () {
    testWidgets('builds KpiCardWidget from item context', (tester) async {
      await pumpItem(
        tester,
        kpiCardItem,
        data: {
          'title': 'MRR',
          'value': '\$9,800',
          'trend': 'up',
          'trendValue': '+12%',
        },
      );
      expect(find.byType(KpiCardWidget), findsOneWidget);
      expect(find.text('MRR'), findsOneWidget);
    });

    testWidgets('rejects a card without its required title and value', (
      tester,
    ) async {
      await expectLater(
        pumpItem(tester, kpiCardItem),
        throwsA(isA<A2uiValidationError>()),
      );
    });
  });
}
