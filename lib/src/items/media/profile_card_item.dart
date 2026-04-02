import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import '../../widgets/media/profile_card.dart';

final profileCardItem = CatalogItem(
  name: 'ProfileCard',
  dataSchema: S.object(
    properties: {
      'name': S.string(),
      'role': S.string(),
      'avatarUrl': S.string(),
      'details': S.list(
        items: S.object(
          properties: {
            'label': S.string(),
            'value': S.string(),
          },
          required: ['label', 'value'],
        ),
      ),
      'actions': S.list(
        items: S.object(
          properties: {
            'label': S.string(),
            'event': S.string(),
          },
          required: ['label', 'event'],
        ),
      ),
    },
    required: ['name'],
  ),
  widgetBuilder: ({
    required Map<String, Object?> data,
    required String id,
    required Widget Function(Widget) buildChild,
    required Function(String event) dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final name = data['name'] as String? ?? '';
    final role = data['role'] as String?;
    final avatarUrl = data['avatarUrl'] as String?;

    final rawDetails = data['details'] as List<dynamic>? ?? [];
    final details = rawDetails
        .whereType<Map<String, dynamic>>()
        .toList();

    final rawActions = data['actions'] as List<dynamic>? ?? [];
    final actions = rawActions
        .whereType<Map<String, dynamic>>()
        .toList();

    return ProfileCardWidget(
      key: ValueKey(id),
      name: name,
      role: role,
      avatarUrl: avatarUrl,
      details: details,
      actions: actions,
      dispatchEvent: dispatchEvent,
    );
  },
);
