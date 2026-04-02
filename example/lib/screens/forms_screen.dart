import 'package:flutter/material.dart';
import 'package:genui_catalog/src/widgets/form/search_bar_widget.dart';
import 'package:genui_catalog/src/widgets/form/rating_input.dart';
import 'package:genui_catalog/src/widgets/form/action_form.dart';
import '../widgets/component_header.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CatalogHeader(
                  catalog: 'FormCatalog',
                  subtitle:
                      'Search inputs, rating pickers, and dynamic action forms for user interaction.',
                  componentCount: 3,
                ),
                const SizedBox(height: 32),

                // ── SearchBar ────────────────────────────────────────────
                const ComponentHeader(
                  name: 'SearchBarWidget',
                  description:
                      'Debounced search field that dispatches a search_query event after a configurable delay.',
                ),
                Builder(
                  builder: (context) => SearchBarWidget(
                    placeholder: 'Search documentation…',
                    debounceMs: 300,
                    minChars: 2,
                    dispatchEvent: (event) {
                      // The widget dispatches "search_query" as the event string.
                      // We want to show the actual query — but the SearchBarWidget
                      // only dispatches a fixed event string. Show a generic snackbar.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Searching documentation…'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // ── RatingInput ──────────────────────────────────────────
                const ComponentHeader(
                  name: 'RatingInputWidget',
                  description:
                      'Interactive star rating widget with optional half-star support.',
                ),
                Builder(
                  builder: (context) => RatingInputWidget(
                    title: 'How would you rate your experience?',
                    label: 'Overall satisfaction',
                    maxStars: 5,
                    allowHalf: true,
                    dispatchEvent: (event) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rating submitted!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // ── ActionForm ───────────────────────────────────────────
                const ComponentHeader(
                  name: 'ActionFormWidget',
                  description:
                      'Schema-driven form with validation, multiple field types, and a success state.',
                ),
                Builder(
                  builder: (context) => ActionFormWidget(
                    title: 'Contact Support',
                    submitLabel: 'Send Message',
                    successMessage:
                        '✓ Message sent! We\'ll reply within 24h.',
                    dispatchEvent: (event) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Form submitted successfully!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    fields: const [
                      {
                        'key': 'name',
                        'label': 'Full Name',
                        'type': 'text',
                        'placeholder': 'Marie Dubois',
                        'required': true,
                      },
                      {
                        'key': 'email',
                        'label': 'Email Address',
                        'type': 'email',
                        'placeholder': 'marie@example.com',
                        'required': true,
                      },
                      {
                        'key': 'subject',
                        'label': 'Subject',
                        'type': 'text',
                        'placeholder': 'Brief description of your issue',
                        'required': true,
                      },
                      {
                        'key': 'message',
                        'label': 'Message',
                        'type': 'textarea',
                        'placeholder':
                            'Describe your issue in detail. Include any error messages or steps to reproduce.',
                        'required': false,
                      },
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
