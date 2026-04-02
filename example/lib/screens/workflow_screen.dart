import 'package:flutter/material.dart';
import 'package:genui_catalog/src/widgets/workflow/status_badge.dart';
import 'package:genui_catalog/src/widgets/workflow/timeline_card.dart';
import 'package:genui_catalog/src/widgets/workflow/stepper_card.dart';
import '../widgets/component_header.dart';

class WorkflowScreen extends StatelessWidget {
  const WorkflowScreen({super.key});

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
                  catalog: 'WorkflowCatalog',
                  subtitle:
                      'Status badges, timelines, and guided steppers for process and deployment workflows.',
                  componentCount: 3,
                ),
                const SizedBox(height: 32),

                // ── StatusBadge ──────────────────────────────────────────
                const ComponentHeader(
                  name: 'StatusBadgeWidget',
                  description:
                      'A colored chip with icon indicating success, warning, error, info, or neutral status.',
                ),
                _SystemStatusCard(),
                const SizedBox(height: 32),

                // ── TimelineCard ─────────────────────────────────────────
                const ComponentHeader(
                  name: 'TimelineCardWidget',
                  description:
                      'Vertical timeline showing sequential events with done/active/pending states.',
                ),
                const TimelineCardWidget(
                  title: 'Deploy #247 — api-service v2.4.1',
                  events: [
                    {
                      'time': 'Apr 2, 09:14 AM',
                      'title': 'Build Triggered',
                      'description':
                          'GitHub Actions pipeline started on merge to main.',
                      'status': 'done',
                    },
                    {
                      'time': 'Apr 2, 09:21 AM',
                      'title': 'Tests Passed',
                      'description':
                          '847 unit tests · 62 integration tests · 0 failures.',
                      'status': 'done',
                    },
                    {
                      'time': 'Apr 2, 09:28 AM',
                      'title': 'Docker Image Published',
                      'description':
                          'api-service:v2.4.1 pushed to registry.internal.',
                      'status': 'done',
                    },
                    {
                      'time': 'Apr 2, 09:32 AM',
                      'title': 'Staging Deploy',
                      'description':
                          'Rolling out to staging-eu-west-1. Smoke tests running.',
                      'status': 'active',
                    },
                    {
                      'time': 'ETA: Apr 2, 10:00 AM',
                      'title': 'Production Release',
                      'description':
                          'Awaiting QA sign-off before production cutover.',
                      'status': 'pending',
                    },
                  ],
                ),
                const SizedBox(height: 32),

                // ── StepperCard ──────────────────────────────────────────
                const ComponentHeader(
                  name: 'StepperCardWidget',
                  description:
                      'Multi-step process navigator with previous/next navigation and event dispatch.',
                ),
                Builder(
                  builder: (context) => StepperCardWidget(
                    title: 'Release Checklist',
                    initialStep: 2,
                    showNavigation: true,
                    dispatchEvent: (event) {
                      final messenger = ScaffoldMessenger.of(context);
                      final label = event == 'next_step'
                          ? 'Moved to next step'
                          : 'Moved to previous step';
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(label),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    steps: const [
                      {
                        'title': 'Code Review',
                        'description':
                            'All PRs reviewed and approved by at least 2 engineers.',
                      },
                      {
                        'title': 'Tests Pass',
                        'description':
                            'CI pipeline green. Unit, integration, and E2E suites all passing.',
                      },
                      {
                        'title': 'Staging Deploy',
                        'description':
                            'Latest build deployed to staging environment and smoke tests run.',
                      },
                      {
                        'title': 'QA Sign-off',
                        'description':
                            'QA team has verified all acceptance criteria and raised no blockers.',
                      },
                      {
                        'title': 'Production Deploy',
                        'description':
                            'Zero-downtime deployment to production with automatic rollback on error.',
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

// ---------------------------------------------------------------------------
// System Status grouped card
// ---------------------------------------------------------------------------

class _SystemStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dns_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Mostly Operational',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                StatusBadgeWidget(
                  label: 'API Gateway',
                  status: 'success',
                  description: 'All endpoints healthy',
                ),
                StatusBadgeWidget(
                  label: 'Database',
                  status: 'success',
                  description: 'Replication in sync',
                ),
                StatusBadgeWidget(
                  label: 'CDN',
                  status: 'warning',
                  description: 'Elevated cache miss rate',
                ),
                StatusBadgeWidget(
                  label: 'Payment API',
                  status: 'error',
                  description: 'Stripe webhook failures',
                ),
                StatusBadgeWidget(
                  label: 'Scheduled Jobs',
                  status: 'info',
                  description: 'Maintenance window active',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
