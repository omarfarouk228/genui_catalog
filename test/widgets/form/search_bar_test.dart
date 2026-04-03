import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/form/search_bar_item.dart';
import '../../helpers.dart';

void main() {
  group('SearchBarWidget', () {
    testWidgets('renders with placeholder', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'placeholder': 'Find something...', 'debounceMs': 300, 'minChars': 2},
        type: 'SearchBar',
      );
      await tester.pumpWidget(wrap(searchBarItem.widgetBuilder(ctx)));
      expect(find.text('Find something...'), findsOneWidget);
    });

    testWidgets('renders search icon', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'debounceMs': 300, 'minChars': 1},
        type: 'SearchBar',
      );
      await tester.pumpWidget(wrap(searchBarItem.widgetBuilder(ctx)));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows clear button after input', (tester) async {
      final ctx = createItemContext(
        buildContext: await getContext(tester),
        data: {'debounceMs': 300, 'minChars': 1},
        type: 'SearchBar',
      );
      await tester.pumpWidget(wrap(searchBarItem.widgetBuilder(ctx)));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
