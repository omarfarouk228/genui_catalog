import 'package:flutter/material.dart';

class StepperCardWidget extends StatefulWidget {
  final String? title;
  final List<Map<String, dynamic>> steps;
  final int initialStep;
  final bool showNavigation;
  final void Function(String event) dispatchEvent;

  const StepperCardWidget({
    super.key,
    this.title,
    required this.steps,
    required this.initialStep,
    required this.showNavigation,
    required this.dispatchEvent,
  });

  @override
  State<StepperCardWidget> createState() => _StepperCardWidgetState();
}

class _StepperCardWidgetState extends State<StepperCardWidget> {
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, widget.steps.length - 1);
  }

  void _goNext() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
      widget.dispatchEvent('next_step');
    }
  }

  void _goPrev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      widget.dispatchEvent('prev_step');
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    final primary = Theme.of(context).colorScheme.primary;

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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
            ],
            // Step indicators
            Row(
              children: List.generate(steps.length, (index) {
                final isCompleted = index < _currentStep;
                final isActive = index == _currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? primary
                                    : isActive
                                        ? primary.withValues(alpha: 0.15)
                                        : Colors.grey[200],
                                border: isActive
                                    ? Border.all(color: primary, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check,
                                        size: 16, color: Colors.white)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isActive
                                              ? primary
                                              : Colors.grey[500],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index < _currentStep
                                ? primary
                                : Colors.grey[300],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Current step content
            if (_currentStep < steps.length) ...[
              Text(
                steps[_currentStep]['title'] as String? ?? '',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                steps[_currentStep]['description'] as String? ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            if (widget.showNavigation) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentStep > 0 ? _goPrev : null,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Previous'),
                  ),
                  TextButton.icon(
                    onPressed:
                        _currentStep < steps.length - 1 ? _goNext : null,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
