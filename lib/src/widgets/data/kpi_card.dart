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

  Color _trendColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (trend) {
      case 'up':
        return Colors.green;
      case 'down':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
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
    final cs = Theme.of(context).colorScheme;
    final accent = accentColor ?? cs.primary;
    final trendColor = _trendColor(context);

    final trendLabel = trend == 'up'
        ? 'trending up${trendValue != null ? ', $trendValue' : ''}'
        : trend == 'down'
        ? 'trending down${trendValue != null ? ', $trendValue' : ''}'
        : null;
    final semanticLabel = [
      '$title: $value',
      if (subtitle != null && subtitle!.isNotEmpty) subtitle!,
      ?trendLabel,
    ].join('. ');

    return Semantics(
      label: semanticLabel,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (subtitle != null && subtitle!.isNotEmpty)
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                subtitle!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (trend != null && trend!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: trendColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _trendIcon(),
                                    size: 12,
                                    color: trendColor,
                                  ),
                                  if (trendValue != null &&
                                      trendValue!.isNotEmpty) ...[
                                    const SizedBox(width: 2),
                                    Text(
                                      trendValue!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: trendColor,
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
      ),
    );
  }
}
