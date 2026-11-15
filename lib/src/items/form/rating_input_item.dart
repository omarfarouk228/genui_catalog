import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';
import '../../catalog_events.dart';
import '../../widgets/form/rating_input.dart';

/// A star rating whose `value` is two-way: bound to a data path
/// (`{"@path": "/rating"}`), it shows the rating there and every tap writes
/// the new one back. Each tap then sends `rating_submitted` with
/// `{rating, maxStars}`, or runs `action` when the agent declares one.
final ratingInputItem = ComponentImplementation(
  name: 'RatingInput',
  schema: Schema.object(
    properties: {
      'title': CatalogSchemas.text,
      'label': CatalogSchemas.text,
      'maxStars': Schema.integer(minimum: 1, maximum: 10),
      'allowHalf': Schema.boolean(),
      'value': CatalogSchemas.number,
      'action': CatalogSchemas.action,
      'noRatingLabel': CatalogSchemas.text,
      'outOfLabel': CatalogSchemas.text,
    },
  ),
  builder: (_, node, props, _) => RatingInputWidget(
    title: props.string('title'),
    label: props.string('label'),
    maxStars: props.integer('maxStars') ?? 5,
    allowHalf: props.boolean('allowHalf') ?? false,
    rating: props.number('value'),
    noRatingLabel: props.string('noRatingLabel') ?? 'No rating',
    outOfLabel: props.string('outOfLabel') ?? 'out of',
    dispatchEvent: (_, eventContext) {
      props.writeBack('value', eventContext['rating']);
      dispatchCatalogEvent(
        node,
        props,
        CatalogEvents.ratingSubmitted,
        context: eventContext,
      );
    },
  ),
);
