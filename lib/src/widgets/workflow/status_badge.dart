import 'package:flutter/material.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final String status;
  final String? description;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.status,
    this.description,
  });

  Color _backgroundColor() {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.amber;
      case 'error':
        return Colors.red;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _backgroundColor();
    final semanticLabel = description != null && description!.isNotEmpty
        ? '$status: $label. $description'
        : '$status: $label';

    return Semantics(
      label: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Chip(
              avatar: Icon(
                _statusIcon(),
                size: 16,
                color: bgColor.withValues(alpha: 0.9),
              ),
              label: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: bgColor,
                ),
              ),
              backgroundColor: bgColor.withValues(alpha: 0.12),
              side: BorderSide(color: bgColor.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
          if (description != null && description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: ExcludeSemantics(
                child: Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
