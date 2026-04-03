import 'package:flutter/material.dart';

class TimelineCardWidget extends StatelessWidget {
  final String? title;
  final List<Map<String, dynamic>> events;

  const TimelineCardWidget({
    super.key,
    this.title,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
            ],
            ...List.generate(events.length, (index) {
              final event = events[index];
              final isLast = index == events.length - 1;
              return _TimelineEvent(
                event: event,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isLast;

  const _TimelineEvent({required this.event, required this.isLast});

  Color _dotColor(String? status, ColorScheme cs) {
    switch (status) {
      case 'done':
        return Colors.green;
      case 'active':
        return cs.primary;
      default:
        return cs.outlineVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = event['time'] as String? ?? '';
    final title = event['title'] as String? ?? '';
    final description = event['description'] as String? ?? '';
    final status = event['status'] as String? ?? 'pending';

    final color = _dotColor(status, cs);

    final semanticLabel = [
      if (time.isNotEmpty) time,
      title,
      if (description.isNotEmpty) description,
      'Status: $status',
    ].join('. ');

    return Semantics(
      label: semanticLabel,
      child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                ExcludeSemantics(child: _buildDot(status, color, cs)),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildDot(String status, Color color, ColorScheme cs) {
    switch (status) {
      case 'done':
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 10, color: cs.onPrimary),
        );
      case 'active':
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
        );
      default:
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cs.outline, width: 2),
          ),
        );
    }
  }
}
