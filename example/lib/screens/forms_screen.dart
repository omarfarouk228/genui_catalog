import 'package:flutter/material.dart';
import 'package:genui_catalog_example/models/preset.dart';
import '../widgets/catalog_demo_screen.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatalogDemoScreen(
      catalogName: 'FormsCatalog',
      subtitle: 'Dynamic forms, dropdowns, checkboxes, toggles, search, and ratings.',
      componentCount: 6,
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
        Preset(
          label: 'Onboarding Preferences',
          icon: Icons.tune_outlined,
          prompt:
              'Build an onboarding preferences screen. '
              'Add a SelectInput labeled "Primary language" with options: '
              'English (en), French (fr), Spanish (es), German (de). '
              'Then a CheckboxGroup labeled "Interests" with options: '
              'Technology, Design, Business, Science, Arts. '
              'Finally a SwitchGroup labeled "Notifications" with options: '
              'Weekly digest (subtitle: Every Monday morning), '
              'Product updates (subtitle: New features and improvements), '
              'Marketing emails (subtitle: Tips and offers). '
              'Pre-enable Weekly digest.',
        ),
        Preset(
          label: 'Privacy Settings',
          icon: Icons.privacy_tip_outlined,
          prompt:
              'Show a privacy settings panel with a SwitchGroup labeled "Data & Privacy" '
              'containing: Analytics (subtitle: Help us improve the app, initially on), '
              'Personalisation (subtitle: Tailored content and recommendations), '
              'Third-party sharing (subtitle: Share data with partners). '
              'Below that, add a SelectInput labeled "Data retention" with options: '
              '30 days, 90 days, 1 year, Forever.',
        ),
      ],
    );
  }
}
