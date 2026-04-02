import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';
import '../../utils/icon_utils.dart';

class StatRowWidget extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const StatRowWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = stats.take(4).toList();
    return Row(
      children: clamped.map((stat) {
        return Expanded(child: _StatCard(stat: stat));
      }).toList(),
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

    final color = (colorStr != null && colorStr.isNotEmpty)
        ? parseHexColor(colorStr)
        : Theme.of(context).colorScheme.primary;

    final iconData = parseIconName(iconName);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
