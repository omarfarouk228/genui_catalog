import 'package:flutter/material.dart';
import 'package:genui_catalog_example/models/preset.dart';
import '../widgets/catalog_demo_screen.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatalogDemoScreen(
      catalogName: 'FormsCatalog',
      subtitle: 'Dynamic forms, search bars, and rating inputs.',
      componentCount: 3,
      accentColor: const Color(0xFF4CAF50),
      icon: Icons.dynamic_form_rounded,
      presets: const [
        Preset(
          label: 'User Feedback',
          icon: Icons.feedback_outlined,
          prompt:
              'Create a user feedback view with a RatingInput for "App Experience" '
              'and an ActionForm to submit a review with fields for Title and Comments.',
        ),
        Preset(
          label: 'Search Settings',
          icon: Icons.manage_search_outlined,
          prompt:
              'Show a SearchBar to find settings, followed by an ActionForm '
              'to update user preferences with fields for Username, Email, and a notification toggle.',
        ),
        Preset(
          label: 'Product Review',
          icon: Icons.rate_review_outlined,
          prompt:
              'Generate a product review section. Include a RatingInput to rate the product, '
              'and an ActionForm asking for "Pros", "Cons", and a detailed "Review Body".',
        ),
      ],
    );
  }
}
