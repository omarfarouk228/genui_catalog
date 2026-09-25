import 'package:flutter/material.dart';

class CheckboxGroupWidget extends StatefulWidget {
  final String? label;
  final List<Map<String, dynamic>> options;
  final List<String> initialValues;
  final String? event;

  /// When set, checking a box stays local and this button dispatches the
  /// selection once. When null, every change is dispatched immediately.
  final String? submitLabel;
  final void Function(String event) dispatchEvent;

  const CheckboxGroupWidget({
    super.key,
    this.label,
    required this.options,
    this.initialValues = const [],
    this.event,
    this.submitLabel,
    required this.dispatchEvent,
  });

  @override
  State<CheckboxGroupWidget> createState() => _CheckboxGroupWidgetState();
}

class _CheckboxGroupWidgetState extends State<CheckboxGroupWidget> {
  late final Set<String> _selected;
  bool _sent = false;

  bool get _submitMode =>
      widget.submitLabel != null && widget.submitLabel!.isNotEmpty;

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
      _sent = false;
    });
    if (!_submitMode) _dispatch();
  }

  void _submit() {
    setState(() => _sent = true);
    _dispatch();
  }

  void _dispatch() {
    if (widget.event != null && widget.event!.isNotEmpty) {
      widget.dispatchEvent('${widget.event}:${_selected.join(',')}');
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
        if (_submitMode) _submitButton(),
      ],
    );
  }
}
