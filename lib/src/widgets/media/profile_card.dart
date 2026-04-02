import 'package:flutter/material.dart';

class ProfileCardWidget extends StatelessWidget {
  final String name;
  final String? role;
  final String? avatarUrl;
  final List<Map<String, dynamic>> details;
  final List<Map<String, dynamic>> actions;
  final void Function(String event) dispatchEvent;

  const ProfileCardWidget({
    super.key,
    required this.name,
    this.role,
    this.avatarUrl,
    required this.details,
    required this.actions,
    required this.dispatchEvent,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (role != null && role!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                role!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (details.isNotEmpty) ...[
              const Divider(height: 24),
              ...details.map((detail) {
                final label = detail['label'] as String? ?? '';
                final value = detail['value'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: actions.map((action) {
                  final label = action['label'] as String? ?? '';
                  final event = action['event'] as String? ?? '';
                  return OutlinedButton(
                    onPressed: () => dispatchEvent(event),
                    child: Text(label),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
