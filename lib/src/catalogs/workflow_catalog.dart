import 'package:genui/genui.dart';
import '../items/workflow/timeline_card_item.dart';
import '../items/workflow/status_badge_item.dart';
import '../items/workflow/stepper_card_item.dart';

export '../items/workflow/timeline_card_item.dart';
export '../items/workflow/status_badge_item.dart';
export '../items/workflow/stepper_card_item.dart';

/// Catalog of workflow components: timelines, status badges, and steppers.
class WorkflowCatalog {
  WorkflowCatalog._();

  /// All items in the workflow catalog.
  static List<CatalogItem> get items => [
    timelineCardItem,
    statusBadgeItem,
    stepperCardItem,
  ];

  /// Returns a [Catalog] containing all workflow catalog items.
  static Catalog asCatalog() => Catalog(items);
}
