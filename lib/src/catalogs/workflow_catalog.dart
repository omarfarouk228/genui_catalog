import 'package:a2ui_flutter/a2ui_flutter.dart';
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
  static List<ComponentImplementation> get items => [
    timelineCardItem,
    statusBadgeItem,
    stepperCardItem,
  ];

  /// Names of all available workflow components.
  static List<String> get itemNames => items.map((i) => i.name).toList();

  /// Catalog ID for workflow components in the GenUI Catalog.
  static const String catalogId = 'genui_catalog/workflow';

  /// Returns a [CatalogImplementation] containing all workflow catalog items.
  static CatalogImplementation asCatalog() => CatalogImplementation(
    id: catalogId,
    components: items,
    instructions:
        'Workflow components available: ${itemNames.join(', ')}. '
        'TimelineCard: ordered list of events with time/title/description/status (done|active|pending). '
        'StatusBadge: colored chip for success|warning|error|info|unknown status. '
        'StepperCard: multi-step wizard with optional navigation buttons '
        '(previousLabel, nextLabel); dispatches next_step and prev_step events. '
        'Tapping a step shows it without dispatching.',
  );
}
