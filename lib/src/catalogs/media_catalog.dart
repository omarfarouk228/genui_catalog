import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';

import '../items/media/profile_card_item.dart';
import '../items/media/media_card_item.dart';

export '../items/media/profile_card_item.dart';
export '../items/media/media_card_item.dart';

/// Catalog of media components: profile cards and media cards.
class MediaCatalog {
  MediaCatalog._();

  /// All components in this catalog.
  static List<ComponentImplementation> get items => [
    profileCardItem,
    mediaCardItem,
  ];

  /// Names of all components in this catalog.
  static List<String> get itemNames => items.map((i) => i.name).toList();

  /// Catalog ID agents put in a component's `catalogId`.
  static const String catalogId =
      'https://github.com/omarfarouk228/genui_catalog/catalogs/media/v1';

  /// Instructions for the agent on using these components.
  static String get instructions =>
      'Components available: ${itemNames.join(', ')}. '
      'ProfileCard: user profile with name, role, avatar, detail rows, and action buttons. '
      'MediaCard: content card with title, body text, image, tags, and action buttons. '
      'Each action button sends its event.';

  /// An A2UI v1.0 catalog of these components. Register it next to the
  /// basic catalog: `MessageProcessor(catalogs: [basicCatalog(), MediaCatalog.asCatalog()])`.
  static CatalogImplementation asCatalog() => CatalogImplementation(
    id: catalogId,
    protocolVersion: A2uiProtocolVersion.v1_0,
    title: 'GenUI Catalog: media',
    components: items,
    instructions: instructions,
  );
}
