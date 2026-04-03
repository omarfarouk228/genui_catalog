import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/media/media_card.dart';

final mediaCardItem = CatalogItem(
  name: 'MediaCard',
  dataSchema: S.object(
    properties: {
      'title': S.string(),
      'content': S.string(),
      'imageUrl': S.string(),
      'tags': S.list(items: S.string()),
      'actions': S.list(
        items: S.object(
          properties: {'label': S.string(), 'event': S.string()},
          required: ['label', 'event'],
        ),
      ),
    },
    required: ['title'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final title = data['title'] as String? ?? '';
    final content = data['content'] as String?;
    final imageUrl = data['imageUrl'] as String?;

    final rawTags = data['tags'] as List<dynamic>? ?? [];
    final tags = rawTags.map((e) => e.toString()).toList();

    final rawActions = data['actions'] as List<dynamic>? ?? [];
    final actions = rawActions.whereType<Map<String, dynamic>>().toList();

    return MediaCardWidget(
      key: ValueKey(itemContext.id),
      title: title,
      content: content,
      imageUrl: imageUrl,
      tags: tags,
      actions: actions,
      dispatchEvent: (eventName) {
        itemContext.dispatchEvent(
          UserActionEvent(name: eventName, sourceComponentId: itemContext.id),
        );
      },
    );
  },
);
