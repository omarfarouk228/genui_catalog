import 'package:flutter/material.dart';

class SelectInputWidget extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final List<Map<String, dynamic>> options;
  final String? initialValue;
  final String? event;
  final void Function(String event) dispatchEvent;

  const SelectInputWidget({
    super.key,
    this.label,
    this.placeholder,
    required this.options,
    this.initialValue,
    this.event,
    required this.dispatchEvent,
  });

  @override
  State<SelectInputWidget> createState() => _SelectInputWidgetState();
}

class _SelectInputWidgetState extends State<SelectInputWidget> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  void _onChanged(String? value) {
    if (value == null) return;
    setState(() => _selected = value);
    if (widget.event != null && widget.event!.isNotEmpty) {
      widget.dispatchEvent('${widget.event}:$value');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final items = widget.options.map((opt) {
      final value = opt['value'] as String? ?? '';
      final label = opt['label'] as String? ?? value;
      return DropdownMenuItem<String>(value: value, child: Text(label));
    }).toList();

    return Semantics(
      label: [
        if (widget.label != null) widget.label!,
        if (_selected != null) 'Selected: $_selected',
      ].join('. '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null && widget.label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ExcludeSemantics(
                child: Text(
                  widget.label!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
          ExcludeSemantics(
            child: DropdownButtonFormField<String>(
              initialValue: _selected,
              hint: widget.placeholder != null
                  ? Text(
                      widget.placeholder!,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    )
                  : null,
              items: items,
              onChanged: _onChanged,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
