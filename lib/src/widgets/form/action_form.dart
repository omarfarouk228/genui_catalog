import 'package:flutter/material.dart';

class ActionFormWidget extends StatefulWidget {
  final String? title;
  final List<Map<String, dynamic>> fields;
  final String submitLabel;
  final String? successMessage;
  final void Function(String event) dispatchEvent;

  const ActionFormWidget({
    super.key,
    this.title,
    required this.fields,
    required this.submitLabel,
    this.successMessage,
    required this.dispatchEvent,
  });

  @override
  State<ActionFormWidget> createState() => _ActionFormWidgetState();
}

class _ActionFormWidgetState extends State<ActionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      final key = field['key'] as String? ?? '';
      if (key.isNotEmpty) {
        _controllers[key] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final values = <String, String>{};
      for (final entry in _controllers.entries) {
        values[entry.key] = entry.value.text;
      }
      widget.dispatchEvent('form_submit');
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null && widget.title!.isNotEmpty) ...[
              Text(
                widget.title!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
            if (_submitted && widget.successMessage != null) ...[
              Builder(
                builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: cs.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.successMessage!,
                            style: TextStyle(color: cs.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ...widget.fields.map((field) {
                      final key = field['key'] as String? ?? '';
                      final label = field['label'] as String? ?? key;
                      final type = field['type'] as String? ?? 'text';
                      final placeholder = field['placeholder'] as String? ?? '';
                      final required = field['required'] as bool? ?? false;
                      final controller =
                          _controllers[key] ?? TextEditingController();
                      final isTextarea = type == 'textarea';
                      final isNumber = type == 'number';
                      final isEmail = type == 'email';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: controller,
                          maxLines: isTextarea ? 4 : 1,
                          keyboardType: isNumber
                              ? TextInputType.number
                              : isEmail
                              ? TextInputType.emailAddress
                              : TextInputType.text,
                          decoration: InputDecoration(
                            labelText: label,
                            hintText: placeholder,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          validator: required
                              ? (v) => (v == null || v.isEmpty)
                                    ? '$label is required'
                                    : null
                              : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit,
                        child: Text(widget.submitLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
