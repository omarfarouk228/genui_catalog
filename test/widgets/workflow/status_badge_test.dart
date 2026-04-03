import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/workflow/status_badge_item.dart';
import 'package:genui_catalog/src/widgets/workflow/status_badge.dart';
import '../../helpers.dart';

void main() {
  group('StatusBadgeWidget', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(wrap(
        const StatusBadgeWidget(label: 'Active', status: 'success'),
      ));
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(wrap(
        const StatusBadgeWidget(label: 'Error', status: 'error', description: 'Connection lost'),
      ));
      expect(find.text('Connection lost'), findsOneWidget);
    });

    testWidgets('omits description when null', (tester) async {
      await tester.pumpWidget(wrap(
        const StatusBadgeWidget(label: 'OK', status: 'success'),
      ));
      expect(find.byType(StatusBadgeWidget), findsOneWidget);
    });

    for (final status in ['success', 'warning', 'error', 'info', 'unknown']) {
      testWidgets('renders without error for status=$status', (tester) async {
        await tester.pumpWidget(wrap(StatusBadgeWidget(label: status, status: status)));
        expect(find.byType(StatusBadgeWidget), findsOneWidget);
      });
    }
  });

  group('statusBadgeItem', () {
    testWidgets('builds widget with label and description', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'label': 'Ready', 'status': 'success', 'description': 'All systems go'},
        type: 'StatusBadge',
      );
      await tester.pumpWidget(wrap(statusBadgeItem.widgetBuilder(ctx)));
      expect(find.byType(StatusBadgeWidget), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('All systems go'), findsOneWidget);
    });
  });
}
