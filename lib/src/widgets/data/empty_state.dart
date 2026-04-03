import 'package:flutter/material.dart';
import '../../utils/icon_utils.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? description;
  final String? iconName;
  final String? actionLabel;
  final String? actionEvent;
  final void Function(String event) dispatchEvent;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.description,
    this.iconName,
    this.actionLabel,
    this.actionEvent,
    required this.dispatchEvent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final iconData = iconName != null && iconName!.isNotEmpty
        ? parseIconName(iconName!)
        : Icons.inbox_outlined;

    final semanticParts = [
      if (title != null && title!.isNotEmpty) title!,
      if (description != null && description!.isNotEmpty) description!,
    ];

    return Semantics(
      label: semanticParts.isNotEmpty ? semanticParts.join('. ') : 'Empty state',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  iconData,
                  size: 64,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              if (title != null && title!.isNotEmpty) ...[
                const SizedBox(height: 16),
                ExcludeSemantics(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: Text(
                    description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (actionLabel != null &&
                  actionLabel!.isNotEmpty &&
                  actionEvent != null &&
                  actionEvent!.isNotEmpty) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => dispatchEvent(actionEvent!),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
