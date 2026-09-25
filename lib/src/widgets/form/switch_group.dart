import 'package:flutter/material.dart';

class SwitchGroupWidget extends StatefulWidget {
  final String? label;
  final List<Map<String, dynamic>> options;
  final List<String> initialValues;
  final String? event;

  /// When set, flipping a switch stays local and this button dispatches
  /// `<event>:<comma-separated values that are on>` once. When null, every
  /// flip dispatches `<event>:<value>:<on|off>` immediately.
  final String? submitLabel;
  final void Function(String event) dispatchEvent;

  const SwitchGroupWidget({
    super.key,
    this.label,
    required this.options,
    this.initialValues = const [],
    this.event,
    this.submitLabel,
    required this.dispatchEvent,
  });

  @override
  State<SwitchGroupWidget> createState() => _SwitchGroupWidgetState();
}

class _SwitchGroupWidgetState extends State<SwitchGroupWidget> {
  late final Set<String> _enabled;
  bool _sent = false;

  bool get _submitMode =>
      widget.submitLabel != null && widget.submitLabel!.isNotEmpty;

  bool get _hasEvent => widget.event != null && widget.event!.isNotEmpty;

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
      _sent = false;
    });
    if (!_submitMode && _hasEvent) {
      widget.dispatchEvent('${widget.event}:$value:${on ? 'on' : 'off'}');
    }
  }

  void _submit() {
    setState(() => _sent = true);
    if (_hasEvent) {
      // Keep the options' order, not the order they were switched on.
      final on = [
        for (final opt in widget.options)
          if (_enabled.contains(opt['value'])) opt['value'] as String,
      ];
      widget.dispatchEvent('${widget.event}:${on.join(',')}');
    }
  }

  /// Submit mode: one button sends the whole selection at once.
  Widget _submitButton() => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SizedBox(
      width: double.infinity,
      child: FilledButton(
        // Disabled once sent, until the selection changes again.
        onPressed: _sent ? null : _submit,
        child: Text(widget.submitLabel!),
      ),
    ),
  );

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
              style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurface),
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
        if (_submitMode) _submitButton(),
      ],
    );
  }
}
