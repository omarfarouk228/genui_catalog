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

  Color _dotColor(String? status) {
    switch (status) {
      case 'done':
        return Colors.green;
      case 'active':
        return Colors.blue;
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = event['time'] as String? ?? '';
    final title = event['title'] as String? ?? '';
    final description = event['description'] as String? ?? '';
    final status = event['status'] as String? ?? 'pending';

    final color = _dotColor(status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _buildDot(status, color),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
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
                        color: Colors.grey[500],
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
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(String status, Color color) {
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
          child: const Icon(Icons.check, size: 10, color: Colors.white),
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
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
        );
    }
  }
}
