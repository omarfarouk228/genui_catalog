import 'package:a2ui_core/a2ui_core.dart' show BasicCatalog;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/genui_catalog.dart';

import '../helpers.dart';

/// End-to-end checks of the catalog components on a real A2UI v1.0 surface:
/// the events they send, the values they write back, and declared actions.
void main() {
  group('catalogs', () {
    test('every sub-catalog is in GenUICatalog.all, once', () {
      final names = GenUICatalog.itemNames;
      expect(names.toSet().length, names.length);
      expect(names, hasLength(19));
      expect(GenUICatalog.findItem('RatingInput'), same(ratingInputItem));
      expect(GenUICatalog.findItem('Nope'), isNull);
    });

    test('catalog ids are distinct URIs and documents serialize', () {
      final catalogs = [
        GenUICatalog.all,
        DataCatalog.asCatalog(),
        WorkflowCatalog.asCatalog(),
        FormCatalog.asCatalog(),
        MediaCatalog.asCatalog(),
      ];
      final ids = catalogs.map((c) => c.id).toSet();
      expect(ids, hasLength(catalogs.length));
      for (final catalog in catalogs) {
        expect(Uri.parse(catalog.id).isAbsolute, isTrue);
        final json = catalog.toJson();
        expect(json['catalogId'] ?? json[r'$id'] ?? catalog.id, isNotNull);
        expect(catalog.instructions, contains('Components available'));
      }
    });
  });

  group('events', () {
    testWidgets('ListCard sends the tapped row event', (tester) async {
      final harness = await pumpItem(tester, listCardItem, {
        'items': [
          {'title': 'Delete', 'event': 'delete_item'},
        ],
      });
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(harness.actions.single.name, 'delete_item');
      expect(harness.actions.single.sourceComponentId, 'root');
    });

    testWidgets('StepperCard sends next_step', (tester) async {
      final harness = await pumpItem(tester, stepperCardItem, {
        'steps': [
          {'title': 'A'},
          {'title': 'B'},
        ],
        'currentStep': 0,
        'showNavigation': true,
      });
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(harness.actions.single.name, CatalogEvents.stepNext);
    });

    testWidgets('MediaCard sends the action button event', (tester) async {
      final harness = await pumpItem(tester, mediaCardItem, {
        'title': 'Post',
        'actions': [
          {'label': 'Share', 'event': 'share_post'},
        ],
      });
      await tester.tap(find.text('Share'));
      await tester.pump();
      expect(harness.actions.single.name, 'share_post');
    });

    testWidgets('EmptyState runs a declared action without actionEvent', (
      tester,
    ) async {
      final harness = await pumpItem(tester, emptyStateItem, {
        'title': 'Nothing yet',
        'actionLabel': 'Create',
        'action': {
          'event': {'name': 'create_first'},
        },
      });
      await tester.tap(find.text('Create'));
      await tester.pump();
      expect(harness.actions.single.name, 'create_first');
    });
  });

  group('bindings', () {
    testWidgets('text properties resolve from the data model', (tester) async {
      await pumpItem(
        tester,
        kpiCardItem,
        {
          'title': 'MRR',
          'value': {'@path': '/mrr'},
        },
        dataModel: {'mrr': r'$9,800'},
      );
      expect(find.text(r'$9,800'), findsOneWidget);
    });

    testWidgets('SearchBar writes the query and sends it', (tester) async {
      final harness = await pumpItem(
        tester,
        searchBarItem,
        {
          'debounceMs': 100,
          'minChars': 2,
          'value': {'@path': '/q'},
        },
        dataModel: {'q': ''},
      );
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump(const Duration(milliseconds: 150));
      expect(harness.data('/q'), 'flutter');
      final action = harness.actions.single;
      expect(action.name, CatalogEvents.searchQuery);
      expect(action.context, {'query': 'flutter'});
    });

    testWidgets('SelectInput writes the selection and sends event:value', (
      tester,
    ) async {
      final harness = await pumpItem(
        tester,
        selectInputItem,
        {
          'event': 'country',
          'value': {'@path': '/country'},
          'options': [
            {'value': 'fr', 'label': 'France'},
            {'value': 'tg', 'label': 'Togo'},
          ],
        },
        dataModel: {'country': 'tg'},
      );
      expect(find.text('Togo'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('France').last);
      await tester.pumpAndSettle();
      expect(harness.data('/country'), 'fr');
      expect(harness.actions.single.name, 'country:fr');
    });

    testWidgets('CheckboxGroup starts from and writes the bound values', (
      tester,
    ) async {
      final harness = await pumpItem(
        tester,
        checkboxGroupItem,
        {
          'event': 'channels',
          'values': {'@path': '/channels'},
          'options': [
            {'value': 'email', 'label': 'Email'},
            {'value': 'sms', 'label': 'SMS'},
          ],
        },
        dataModel: {
          'channels': ['email'],
        },
      );
      await tester.tap(find.text('SMS'));
      await tester.pump();
      expect(harness.data('/channels'), ['email', 'sms']);
      expect(harness.actions.single.name, 'channels:email,sms');
    });

    testWidgets('SwitchGroup writes the switched-on values in order', (
      tester,
    ) async {
      final harness = await pumpItem(
        tester,
        switchGroupItem,
        {
          'values': {'@path': '/on'},
          'options': [
            {'value': 'a', 'label': 'A'},
            {'value': 'b', 'label': 'B'},
          ],
        },
        dataModel: {
          'on': ['b'],
        },
      );
      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      expect(harness.data('/on'), ['a', 'b']);
      // No `event`: nothing is sent.
      expect(harness.actions, isEmpty);
    });

    testWidgets('a basic Button can submit what the inputs wrote', (
      tester,
    ) async {
      final harness = await A2uiHarness.pump(
        tester,
        catalog: FormCatalog.asCatalog(),
        dataModel: {'rating': 0},
        components: [
          {
            'id': 'root',
            'component': 'Column',
            'catalogId': BasicCatalog.v1_0Id,
            'children': ['stars', 'send'],
          },
          {
            'id': 'stars',
            'component': 'RatingInput',
            'catalogId': FormCatalog.catalogId,
            'value': {'@path': '/rating'},
          },
          {
            'id': 'send',
            'component': 'Button',
            'catalogId': BasicCatalog.v1_0Id,
            'child': 'label',
            'action': {
              'event': {
                'name': 'review',
                'context': {
                  'stars': {'@path': '/rating'},
                },
              },
            },
          },
          {
            'id': 'label',
            'component': 'Text',
            'catalogId': BasicCatalog.v1_0Id,
            'text': 'Send',
          },
        ],
      );
      await tester.tap(find.byIcon(Icons.star_border).at(2));
      await tester.pump();
      await tester.tap(find.text('Send'));
      await tester.pump();
      expect(harness.data('/rating'), 3);
      expect(harness.actions.last.name, 'review');
      expect(harness.actions.last.context, {'stars': 3});
    });
  });

  group('layout', () {
    testWidgets('Column renders catalog and basic children', (tester) async {
      final harness = await A2uiHarness.pump(
        tester,
        catalog: GenUICatalog.all,
        components: [
          {
            'id': 'root',
            'component': 'Column',
            'catalogId': GenUICatalog.catalogId,
            'spacing': 8,
            'children': ['a', 'b'],
          },
          {
            'id': 'a',
            'component': 'StatusBadge',
            'catalogId': GenUICatalog.catalogId,
            'label': 'One',
            'status': 'success',
          },
          {
            'id': 'b',
            'component': 'Text',
            'catalogId': BasicCatalog.v1_0Id,
            'text': 'Two',
          },
        ],
      );
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(harness.errors, isEmpty);
    });
  });
}
