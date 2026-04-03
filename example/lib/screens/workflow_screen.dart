import 'package:flutter/material.dart';
import '../widgets/catalog_demo_screen.dart';

class WorkflowScreen extends StatelessWidget {
  const WorkflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatalogDemoScreen(
      catalogName: 'WorkflowCatalog',
      subtitle:
          'Timelines, status badges, and step navigators — for process-driven UIs.',
      componentCount: 3,
      accentColor: const Color(0xFFFF9800),
      icon: Icons.account_tree_rounded,
      presets: const [
        _Preset(
          label: 'Order Status',
          icon: Icons.local_shipping_outlined,
          prompt:
              'Show an order status view with a TimelineCard tracking an '
              'e-commerce order: Order Placed (done, Jan 12 10:00), Payment '
              'Confirmed (done, Jan 12 10:05), Preparing (done, Jan 13 09:00), '
              'Shipped (active, Jan 14 14:30), Out for Delivery (pending), '
              'Delivered (pending). Also add a StatusBadge "In Transit" with '
              'status info.',
        ),
        _Preset(
          label: 'Deployment Pipeline',
          icon: Icons.rocket_launch_outlined,
          prompt:
              'Create a CI/CD deployment pipeline view with a StepperCard '
              'showing steps: Code Review (description: PR approved by 2 '
              'reviewers), Tests (All 142 tests passing), Build (Docker image '
              'built and pushed), Staging Deploy (Deployed to staging.example.com), '
              'Production Deploy (description: Awaiting approval) — currentStep 3, '
              'showNavigation true. Add a StatusBadge "Awaiting Approval" with '
              'status warning.',
        ),
        _Preset(
          label: 'Incident Timeline',
          icon: Icons.warning_amber_outlined,
          prompt:
              'Generate an incident response timeline with a TimelineCard: '
              'Alert Triggered (done, 14:32), On-call Paged (done, 14:33), '
              'Investigation Started (done, 14:38), Root Cause Identified '
              '(done, 15:10 — database connection pool exhausted), Fix Deployed '
              '(active, 15:45), Monitoring (pending). Add StatusBadges for '
              '"Severity P1" (error) and "Status: Resolving" (warning).',
        ),
        _Preset(
          label: 'Onboarding Flow',
          icon: Icons.person_add_outlined,
          prompt:
              'Show a user onboarding flow with a StepperCard: Create Account, '
              'Verify Email, Set Up Profile, Connect Integrations, Invite Team — '
              'currentStep 2, showNavigation true. Also add a TimelineCard '
              'showing the onboarding progress: Welcome Email (done), Profile '
              'Setup (active), First Project (pending), Invite Colleagues (pending).',
        ),
      ],
    );
  }
}
