import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/items/form/search_bar_item.dart';
import '../../helpers.dart';

void main() {
  group('SearchBarWidget', () {
    testWidgets('renders with placeholder', (tester) async {
      await pumpItem(
        tester,
        searchBarItem,
        data: {
          'placeholder': 'Find something...',
          'debounceMs': 300,
          'minChars': 2,
        },
      );
      expect(find.text('Find something...'), findsOneWidget);
    });

    testWidgets('renders search icon', (tester) async {
      await pumpItem(
        tester,
        searchBarItem,
        data: {'debounceMs': 300, 'minChars': 1},
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows clear button after input', (tester) async {
      await pumpItem(
        tester,
        searchBarItem,
        data: {'debounceMs': 300, 'minChars': 1},
      );
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
