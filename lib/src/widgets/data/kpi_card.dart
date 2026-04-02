import 'package:flutter/material.dart';

class KpiCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final String? trendValue;
  final Color? accentColor;

  const KpiCardWidget({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.trendValue,
    this.accentColor,
  });

  Color _trendColor() {
    switch (trend) {
      case 'up':
        return Colors.green;
      case 'down':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _trendIcon() {
    switch (trend) {
      case 'up':
        return Icons.arrow_upward;
      case 'down':
        return Icons.arrow_downward;
      default:
        return Icons.arrow_forward;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Expanded(
                            child: Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (trend != null && trend!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _trendColor().withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_trendIcon(), size: 12, color: _trendColor()),
                                if (trendValue != null && trendValue!.isNotEmpty) ...[
                                  const SizedBox(width: 2),
                                  Text(
                                    trendValue!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _trendColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
