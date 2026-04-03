import 'package:flutter/material.dart';
import '../../utils/icon_utils.dart';

class ListCardWidget extends StatelessWidget {
  final String? title;
  final List<Map<String, dynamic>> items;
  final bool showDividers;
  final void Function(String event) dispatchEvent;

  const ListCardWidget({
    super.key,
    this.title,
    required this.items,
    this.showDividers = true,
    required this.dispatchEvent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => showDividers
                ? const Divider(height: 1)
                : const SizedBox.shrink(),
            itemBuilder: (context, index) {
              final item = items[index];
              final itemTitle = item['title'] as String? ?? '';
              final subtitle = item['subtitle'] as String?;
              final iconName = item['icon'] as String?;
              final trailingText = item['trailingText'] as String?;
              final event = item['event'] as String? ?? '';
              final isDestructive = item['destructive'] as bool? ?? false;

              final iconData = iconName != null && iconName.isNotEmpty
                  ? parseIconName(iconName)
                  : null;

              final textColor = isDestructive ? cs.error : null;

              return Semantics(
                label: [itemTitle, ?subtitle].join(', '),
                button: event.isNotEmpty,
                child: ListTile(
                  onTap: event.isNotEmpty ? () => dispatchEvent(event) : null,
                  leading: iconData != null
                      ? Icon(
                          iconData,
                          color: isDestructive ? cs.error : cs.onSurfaceVariant,
                        )
                      : null,
                  title: Text(itemTitle, style: TextStyle(color: textColor)),
                  subtitle: subtitle != null && subtitle.isNotEmpty
                      ? Text(
                          subtitle,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        )
                      : null,
                  trailing: trailingText != null && trailingText.isNotEmpty
                      ? Text(
                          trailingText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        )
                      : event.isNotEmpty
                      ? Icon(Icons.chevron_right, color: cs.onSurfaceVariant)
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
