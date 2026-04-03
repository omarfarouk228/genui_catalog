import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/form/rating_input.dart';

final ratingInputItem = CatalogItem(
  name: 'RatingInput',
  dataSchema: S.object(
    properties: {
      'title': S.string(),
      'maxStars': S.integer(),
      'label': S.string(),
      'allowHalf': S.boolean(),
    },
    required: [],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final title = data['title'] as String?;
    final maxStars = data['maxStars'] as int? ?? 5;
    final label = data['label'] as String?;
    final allowHalf = data['allowHalf'] as bool? ?? false;

    return RatingInputWidget(
      key: ValueKey(itemContext.id),
      title: title,
      maxStars: maxStars,
      label: label,
      allowHalf: allowHalf,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
