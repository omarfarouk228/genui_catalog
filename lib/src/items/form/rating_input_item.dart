import 'dart:async';

import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/rating_input.dart';

final ratingInputItem = ComponentImplementation(
  name: 'RatingInput',
  schema: S.object(
    properties: {
      'title': S.string(),
      'maxStars': S.integer(),
      'label': S.string(),
      'allowHalf': S.boolean(),
      'noRatingLabel': S.string(),
      'outOfLabel': S.string(),
    },
    required: [],
  ),
  builder: (context, node, props, buildChild) {
    final title = props.string('title');
    final maxStars = props.number('maxStars')?.toInt() ?? 5;
    final label = props.string('label');
    final allowHalf = props.boolean('allowHalf') ?? false;

    return RatingInputWidget(
      key: ValueKey(node.componentId),
      title: title,
      maxStars: maxStars,
      label: label,
      allowHalf: allowHalf,
      noRatingLabel: props.string('noRatingLabel') ?? 'No rating',
      outOfLabel: props.string('outOfLabel') ?? 'out of',
      dispatchEvent: (eventName, eventContext) {
        unawaited(
          node.context?.dispatchAction({
            'event': {'name': eventName, 'context': eventContext},
          }),
        );
      },
    );
  },
);
