import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/data/list_card.dart';

final listCardItem = CatalogItem(
  name: 'ListCard',
  dataSchema: S.object(
    properties: {
      'title': S.string(),
      'showDividers': S.boolean(),
      'items': S.list(
        items: S.object(
          properties: {
            'title': S.string(),
            'subtitle': S.string(),
            'icon': S.string(),
            'trailingText': S.string(),
            'event': S.string(),
            'destructive': S.boolean(),
          },
          required: ['title'],
        ),
      ),
    },
    required: ['items'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final items = rawItems.whereType<Map<String, dynamic>>().toList();

    return ListCardWidget(
      key: ValueKey(itemContext.id),
      title: data['title'] as String?,
      showDividers: data['showDividers'] as bool? ?? true,
      items: items,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
