import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:genui_catalog/src/items/form/action_form_item.dart';
import 'package:genui_catalog/src/items/workflow/status_badge_item.dart';
import 'package:genui_catalog/src/widgets/workflow/status_badge.dart';

CatalogItemContext _createItemContext({
  required BuildContext buildContext,
  Object data = const {},
  String id = 'test-id',
  String type = 'Test',
  void Function(UiEvent)? onDispatch,
}) {
  return CatalogItemContext(
    data: data,
    id: id,
    type: type,
    buildChild: (id, [dataContext]) => const SizedBox.shrink(),
    dispatchEvent: onDispatch ?? (_) {},
    buildContext: buildContext,
    dataContext: DataContext(InMemoryDataModel(), DataPath.root),
    getComponent: (_) => null,
    getCatalogItem: (_) => null,
    surfaceId: 'surface-1',
    reportError: (error, stack) {},
  );
}

void main() {
  testWidgets(
    'StatusBadge item builds StatusBadgeWidget with label and description',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      final buildContext = tester.element(find.byType(SizedBox));

      final context = _createItemContext(
        buildContext: buildContext,
        data: {
          'label': 'Ready',
          'status': 'success',
          'description': 'All systems go',
        },
        id: 'badge-1',
        type: 'StatusBadge',
      );

      final widget = statusBadgeItem.widgetBuilder(context);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.byType(StatusBadgeWidget), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('All systems go'), findsOneWidget);
    },
  );

  testWidgets('ActionForm item dispatches UserActionEvent on submit', (
    tester,
  ) async {
    final events = <UiEvent>[];

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    final buildContext = tester.element(find.byType(SizedBox));

    final context = _createItemContext(
      buildContext: buildContext,
      data: {
        'fields': [
          {'key': 'name', 'label': 'Name', 'type': 'text', 'required': true},
        ],
        'submitLabel': 'Send',
      },
      id: 'form-1',
      type: 'ActionForm',
      onDispatch: (event) => events.add(event),
    );

    final widget = actionFormItem.widgetBuilder(context);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    await tester.enterText(find.byType(TextFormField), 'Bob');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(events, isNotEmpty);
    expect(events.first, isA<UserActionEvent>());
    expect((events.first as UserActionEvent).name, equals('form_submit'));
  });
}
