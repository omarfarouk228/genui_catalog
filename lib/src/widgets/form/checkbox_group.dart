import 'package:flutter/material.dart';

class CheckboxGroupWidget extends StatefulWidget {
  final String? label;
  final List<Map<String, dynamic>> options;
  final List<String> initialValues;
  final String? event;
  final void Function(String event) dispatchEvent;

  const CheckboxGroupWidget({
    super.key,
    this.label,
    required this.options,
    this.initialValues = const [],
    this.event,
    required this.dispatchEvent,
  });

  @override
  State<CheckboxGroupWidget> createState() => _CheckboxGroupWidgetState();
}

class _CheckboxGroupWidgetState extends State<CheckboxGroupWidget> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initialValues);
  }

  void _toggle(String value, bool? checked) {
    setState(() {
      if (checked == true) {
        _selected.add(value);
      } else {
        _selected.remove(value);
      }
    });
    if (widget.event != null && widget.event!.isNotEmpty) {
      widget.dispatchEvent('${widget.event}:${_selected.join(',')}');
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
          final isChecked = _selected.contains(value);

          return Semantics(
            checked: isChecked,
            label: label,
            child: CheckboxListTile(
              value: isChecked,
              title: ExcludeSemantics(child: Text(label)),
              onChanged: (v) => _toggle(value, v),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          );
        }),
      ],
    );
  }
}
