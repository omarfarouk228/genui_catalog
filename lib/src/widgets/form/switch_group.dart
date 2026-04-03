import 'package:flutter/material.dart';

class SwitchGroupWidget extends StatefulWidget {
  final String? label;
  final List<Map<String, dynamic>> options;
  final List<String> initialValues;
  final String? event;
  final void Function(String event) dispatchEvent;

  const SwitchGroupWidget({
    super.key,
    this.label,
    required this.options,
    this.initialValues = const [],
    this.event,
    required this.dispatchEvent,
  });

  @override
  State<SwitchGroupWidget> createState() => _SwitchGroupWidgetState();
}

class _SwitchGroupWidgetState extends State<SwitchGroupWidget> {
  late final Set<String> _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = Set<String>.from(widget.initialValues);
  }

  void _toggle(String value, bool on) {
    setState(() {
      if (on) {
        _enabled.add(value);
      } else {
        _enabled.remove(value);
      }
    });
    if (widget.event != null && widget.event!.isNotEmpty) {
      widget.dispatchEvent('${widget.event}:$value:${on ? 'on' : 'off'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.label!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        ...widget.options.map((opt) {
          final value = opt['value'] as String? ?? '';
          final label = opt['label'] as String? ?? value;
          final subtitle = opt['subtitle'] as String?;
          final isOn = _enabled.contains(value);

          return Semantics(
            toggled: isOn,
            label: label,
            child: SwitchListTile(
              value: isOn,
              title: ExcludeSemantics(child: Text(label)),
              subtitle: subtitle != null && subtitle.isNotEmpty
                  ? ExcludeSemantics(
                      child: Text(
                        subtitle,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    )
                  : null,
              onChanged: (v) => _toggle(value, v),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          );
        }),
      ],
    );
  }
}
