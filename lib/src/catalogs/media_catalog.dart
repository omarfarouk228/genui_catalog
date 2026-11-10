import 'package:a2ui_flutter/a2ui_flutter.dart';
import '../items/media/profile_card_item.dart';
import '../items/media/media_card_item.dart';

export '../items/media/profile_card_item.dart';
export '../items/media/media_card_item.dart';

/// Catalog of media components: profile cards and media cards.
class MediaCatalog {
  MediaCatalog._();

  /// All items in the media catalog.
  static List<ComponentImplementation> get items => [
    profileCardItem,
    mediaCardItem,
  ];

  /// Names of all available media components.
  static List<String> get itemNames => items.map((i) => i.name).toList();

  /// Catalog ID for media components in the GenUI Catalog.
  static const String catalogId = 'genui_catalog/media';

  /// Returns a [CatalogImplementation] containing all media catalog items.
  static CatalogImplementation asCatalog() => CatalogImplementation(
    id: catalogId,
    components: items,
    instructions:
        'Media components available: ${itemNames.join(', ')}. '
        'ProfileCard: user profile with name, role, avatar, detail rows, and action buttons. '
        'MediaCard: content card with title, body text, image, tags, and action buttons.',
  );
}
