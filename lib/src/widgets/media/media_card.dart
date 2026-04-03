import 'package:flutter/material.dart';

class MediaCardWidget extends StatelessWidget {
  final String title;
  final String? content;
  final String? imageUrl;
  final List<String> tags;
  final List<Map<String, dynamic>> actions;
  final void Function(String event) dispatchEvent;

  const MediaCardWidget({
    super.key,
    required this.title,
    this.content,
    this.imageUrl,
    required this.tags,
    required this.actions,
    required this.dispatchEvent,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = [
      title,
      if (content != null && content!.isNotEmpty) content!,
      if (tags.isNotEmpty) 'Tags: ${tags.join(', ')}',
    ].join('. ');

    return Semantics(
      label: semanticLabel,
      child: Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Image.network(
              imageUrl!,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: Icon(Icons.broken_image, size: 40)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (content != null && content!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    content!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: actions.map((action) {
                      final label = action['label'] as String? ?? '';
                      final event = action['event'] as String? ?? '';
                      return TextButton(
                        onPressed: () => dispatchEvent(event),
                        child: Text(label),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
