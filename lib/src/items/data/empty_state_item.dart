import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/empty_state.dart';

final emptyStateItem = CatalogItem(
  name: 'EmptyState',
  dataSchema: S.object(
    properties: {
      'title': S.string(),
      'description': S.string(),
      'icon': S.string(),
      'actionLabel': S.string(),
      'actionEvent': S.string(),
    },
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;

    return EmptyStateWidget(
      key: ValueKey(itemContext.id),
      title: data['title'] as String?,
      description: data['description'] as String?,
      iconName: data['icon'] as String?,
      actionLabel: data['actionLabel'] as String?,
      actionEvent: data['actionEvent'] as String?,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
