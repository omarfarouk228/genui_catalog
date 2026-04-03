import 'package:genui/genui.dart';
import '../items/media/profile_card_item.dart';
import '../items/media/media_card_item.dart';

export '../items/media/profile_card_item.dart';
export '../items/media/media_card_item.dart';

/// Catalog of media components: profile cards and media cards.
class MediaCatalog {
  MediaCatalog._();

  /// All items in the media catalog.
  static List<CatalogItem> get items => [profileCardItem, mediaCardItem];

  /// Returns a [Catalog] containing all media catalog items.
  static Catalog asCatalog() => Catalog(items);
}
