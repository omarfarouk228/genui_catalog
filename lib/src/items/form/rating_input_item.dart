import 'dart:async';
import 'dart:developer';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../widgets/form/rating_input.dart';

/// `RatingInput`: a star rating whose `value` is two-way.
///
/// Bind `value` to a data path (`{"@path": "/rating"}`) to receive the rating
/// in the data model; `action` runs on every tap, so the agent can reference
/// the same path in the action's `context`:
///
/// ```json
/// {
///   "id": "rating",
///   "component": "RatingInput",
///   "catalogId": "<FormCatalog.catalogId>",
///   "maxStars": 5,
///   "value": {"@path": "/rating"},
///   "action": {
///     "event": {"name": "rating_submitted", "context": {"rating": {"@path": "/rating"}}}
///   }
/// }
/// ```
///
/// The action also carries `{rating, maxStars}` in its metadata, under
/// `extensions.genui_catalog`, so a host can read the rating even when `value`
/// is not bound.
final ratingInputItem = ComponentImplementation(
  name: 'RatingInput',
  schema: Schema.object(
    properties: {
      'title': CommonSchemasV1.dynamicString,
      'label': CommonSchemasV1.dynamicString,
      'maxStars': Schema.integer(minimum: 1, maximum: 10),
      'allowHalf': Schema.boolean(),
      'value': CommonSchemasV1.dynamicNumber,
      'action': Schema.fromMap({r'$ref': r'common_types.json#/$defs/Action'}),
      'noRatingLabel': CommonSchemasV1.dynamicString,
      'outOfLabel': CommonSchemasV1.dynamicString,
    },
  ),
  builder: (context, node, props, buildChild) {
    final WritableBinding<Object?>? value = props.writable('value');
    final int maxStars = (props.number('maxStars') ?? 5).toInt();

    return RatingInputWidget(
      title: props.string('title'),
      label: props.string('label'),
      maxStars: maxStars,
      allowHalf: props.boolean('allowHalf') ?? false,
      rating: props.number('value'),
      noRatingLabel: props.string('noRatingLabel') ?? 'No rating',
      outOfLabel: props.string('outOfLabel') ?? 'out of',
      dispatchEvent: (_, eventContext) {
        final Object? rating = eventContext['rating'];
        try {
          value?.set(rating);
        } on A2uiDataError catch (error) {
          log('${error.code}: ${error.message}', name: 'genui_catalog');
        }
        // Called synchronously from the tap: A2UI runs actions as user
        // activations.
        unawaited(
          props
              .action('action')
              ?.call(
                ActionDispatchOptions(
                  metadata: {
                    'extensions': {
                      'genui_catalog': {'rating': rating, 'maxStars': maxStars},
                    },
                  },
                ),
              ),
        );
      },
    );
  },
);
