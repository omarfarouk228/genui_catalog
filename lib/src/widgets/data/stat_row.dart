import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';
import '../../utils/icon_utils.dart';

class StatRowWidget extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const StatRowWidget({super.key, required this.stats});

  static const _limit = 4;

  @override
  Widget build(BuildContext context) {
    assert(
      stats.length <= _limit,
      'StatRow received ${stats.length} stats but only $_limit are displayed. '
      'Split into multiple StatRow widgets for more stats.',
    );
    final clamped = stats.take(_limit).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isFinite) {
          final itemWidth = constraints.maxWidth / clamped.length;
          return Row(
            children: clamped.map((stat) {
              return SizedBox(
                width: itemWidth,
                child: _StatCard(stat: stat),
              );
            }).toList(),
          );
        }

        // Fallback for unbounded width contexts (e.g. horizontal scroll, flex
        // without tight constraints).
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: clamped.map((stat) {
            return SizedBox(width: 240, child: _StatCard(stat: stat));
          }).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final label = stat['label'] as String? ?? '';
    final value = stat['value'] as String? ?? '';
    final iconName = stat['icon'] as String? ?? '';
    final colorStr = stat['color'] as String?;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final color = (colorStr != null && colorStr.isNotEmpty)
        ? parseHexColor(colorStr, fallback: primaryColor)
        : primaryColor;

    final iconData = parseIconName(iconName);

    return Semantics(
      label: '$value, $label',
      child: ExcludeSemantics(
        excluding: false,
        child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: color, size: 22),
                  ),
                ),
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
