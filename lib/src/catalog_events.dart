/// Typed constants for all events dispatched by GenUI Catalog widgets.
///
/// Use these instead of raw strings when listening to [UserActionEvent.name]
/// in your [SurfaceController] or event handlers.
///
/// Example:
/// ```dart
/// if (event.name == CatalogEvents.formSubmit) { ... }
/// ```
abstract final class CatalogEvents {
  // Form
  /// Dispatched by [ActionFormWidget] when the form is submitted successfully.
  static const String formSubmit = 'form_submit';

  /// Dispatched by [RatingInputWidget] when the user selects a rating.
  static const String ratingSubmitted = 'rating_submitted';

  /// Dispatched by [SearchBarWidget] when the query meets the minimum length
  /// after the debounce delay.
  static const String searchQuery = 'search_query';

  // Workflow
  /// Dispatched by [StepperCardWidget] when the user advances to the next step.
  static const String stepNext = 'next_step';

  /// Dispatched by [StepperCardWidget] when the user goes back to the previous step.
  static const String stepPrev = 'prev_step';

  // Data
  /// Prefix for events dispatched by [ListCardWidget] items.
  /// The full event name is whatever string is set in the item's `event` field.
  static const String listItemTapped = 'list_item_tapped';

  /// Dispatched by [EmptyStateWidget] when the action button is tapped.
  /// The full event name is whatever string is set in `actionEvent`.
  static const String emptyStateAction = 'empty_state_action';

  // Selection
  /// Prefix dispatched by [SelectInputWidget]: full event is `<event>:<value>`.
  static const String optionSelected = 'option_selected';

  /// Prefix dispatched by [CheckboxGroupWidget]: full event is `<event>:<csv values>`.
  static const String selectionChanged = 'selection_changed';

  /// Prefix dispatched by [SwitchGroupWidget]: full event is `<event>:<value>:<on|off>`.
  static const String switchChanged = 'switch_changed';
}
