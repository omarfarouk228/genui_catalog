import 'package:flutter/material.dart';
import 'package:genui_catalog_example/models/preset.dart';
import '../widgets/catalog_demo_screen.dart';

class AiDemoScreen extends StatelessWidget {
  const AiDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatalogDemoScreen(
      catalogName: 'GenUI Mixed Demo',
      subtitle:
          'Combine any components from the catalog to build complex screens.',
      componentCount: 12,
      accentColor: const Color(0xFF5C35CC),
      icon: Icons.auto_awesome,
      presets: const [
        Preset(
          label: 'Admin Dashboard',
          icon: Icons.admin_panel_settings_outlined,
          prompt:
              'Generate an admin dashboard. Top: a SearchBar. Next: a StatRow with '
              '3 metrics (Users, Revenue, Uptime). Next: a DataTable with recent signups. '
              'Bottom: a KpiCard for Monthly Growth.',
        ),
        Preset(
          label: 'Employee Onboarding',
          icon: Icons.badge_outlined,
          prompt:
              'Create an employee onboarding view. Start with a ProfileCard of the new employee. '
              'Next, a StepperCard showing onboarding steps (Docs, IT Setup, Training). '
              'Add a TimelineCard for today\'s orientation schedule.',
        ),
        Preset(
          label: 'E-commerce Product',
          icon: Icons.shopping_bag_outlined,
          prompt:
              'Show a product detail view. Top: a MediaCard with the product image and tags. '
              'Middle: a RatingInput showing the average score. Bottom: an ActionForm to "Add to Cart".',
        ),
      ],
    );
  }
}
