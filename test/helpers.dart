import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

CatalogItemContext createItemContext({
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

Widget wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Future<BuildContext> getContext(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
  return tester.element(find.byType(SizedBox));
}
