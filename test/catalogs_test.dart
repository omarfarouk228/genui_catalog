import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/genui_catalog.dart';

void main() {
  group('GenUICatalog', () {
    test('combines the components and instructions of every sub-catalog', () {
      final catalog = GenUICatalog.asCatalog();
      expect(catalog.id, GenUICatalog.catalogId);
      expect(catalog.components.keys, unorderedEquals(GenUICatalog.itemNames));
      for (final subCatalog in [
        DataCatalog.asCatalog(),
        WorkflowCatalog.asCatalog(),
        FormCatalog.asCatalog(),
        MediaCatalog.asCatalog(),
      ]) {
        expect(catalog.instructions, contains(subCatalog.instructions));
      }
    });
  });
}
