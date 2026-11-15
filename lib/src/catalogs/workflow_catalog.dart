import 'package:a2ui_core/a2ui_core.dart';
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

  /// All components in this catalog.
  static List<ComponentImplementation> get items => [
    timelineCardItem,
    statusBadgeItem,
    stepperCardItem,
  ];

  /// Names of all components in this catalog.
  static List<String> get itemNames => items.map((i) => i.name).toList();

  /// Catalog ID agents put in a component's `catalogId`.
  static const String catalogId =
      'https://github.com/omarfarouk228/genui_catalog/catalogs/workflow/v1';

  /// Instructions for the agent on using these components.
  static String get instructions =>
      'Components available: ${itemNames.join(', ')}. '
      'TimelineCard: ordered list of events with time/title/description/status (done|active|pending). '
      'StatusBadge: colored chip for success|warning|error|info|unknown status. '
      'StepperCard: multi-step wizard with optional navigation buttons '
      '(previousLabel, nextLabel); sends next_step and prev_step events. '
      'Tapping a step shows it without sending anything.';

  /// An A2UI v1.0 catalog of these components. Register it next to the
  /// basic catalog: `MessageProcessor(catalogs: [basicCatalog(), WorkflowCatalog.asCatalog()])`.
  static CatalogImplementation asCatalog() => CatalogImplementation(
    id: catalogId,
    protocolVersion: A2uiProtocolVersion.v1_0,
    title: 'GenUI Catalog: workflow',
    components: items,
    instructions: instructions,
  );
}
