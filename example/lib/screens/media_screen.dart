import 'package:flutter/material.dart';
import 'package:genui_catalog/src/widgets/media/profile_card.dart';
import 'package:genui_catalog/src/widgets/media/media_card.dart';
import '../widgets/component_header.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

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
                  catalog: 'MediaCatalog',
                  subtitle:
                      'Profile cards and media cards for team directories, blogs, and content feeds.',
                  componentCount: 2,
                ),
                const SizedBox(height: 32),

                // ── ProfileCard ──────────────────────────────────────────
                const ComponentHeader(
                  name: 'ProfileCardWidget',
                  description:
                      'Avatar (or initials fallback), name, role, detail rows, and action buttons.',
                ),

                // Two profile cards side by side on wide screens
                _ProfileCardsRow(),
                const SizedBox(height: 32),

                // ── MediaCard ────────────────────────────────────────────
                const ComponentHeader(
                  name: 'MediaCardWidget',
                  description:
                      'Content card with optional image, title, body text, tag chips, and action buttons.',
                ),
                Builder(
                  builder: (context) => MediaCardWidget(
                    title: 'Building AI-driven UIs with GenUI',
                    content:
                        'A practical guide to using schema-driven components to let LLMs generate rich dashboards without any frontend code from the AI side.',
                    tags: const ['Flutter', 'AI', 'GenUI', 'Tutorial'],
                    actions: const [
                      {'label': 'Read Article', 'event': 'read_article'},
                      {'label': 'Bookmark', 'event': 'bookmark'},
                    ],
                    dispatchEvent: (event) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${event == 'read_article' ? 'Opening article…' : 'Bookmarked!'}'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) => MediaCardWidget(
                    title: 'GenUI Catalog v0.1.0 Released',
                    content:
                        'Today we\'re releasing the first version of genui_catalog, a set of 12 production-ready CatalogItems for the genui SDK.',
                    tags: const ['Release', 'Open Source'],
                    actions: const [
                      {'label': 'Read More', 'event': 'read_more'},
                      {'label': 'Share', 'event': 'share'},
                    ],
                    dispatchEvent: (event) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              event == 'share' ? 'Link copied to clipboard!' : 'Opening post…'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
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
// Profile cards — responsive row or column
// ---------------------------------------------------------------------------

class _ProfileCardsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    final marie = Builder(
      builder: (context) => ProfileCardWidget(
        name: 'Marie Dubois',
        role: 'Lead Product Designer',
        details: const [
          {'label': 'Email', 'value': 'marie@genui.dev'},
          {'label': 'Location', 'value': 'Paris, France'},
          {'label': 'Experience', 'value': '8 years'},
        ],
        actions: const [
          {'label': 'Message', 'event': 'message'},
          {'label': 'View Portfolio', 'event': 'view_portfolio'},
        ],
        dispatchEvent: (event) {
          final msg = event == 'message'
              ? 'Opening message thread with Marie…'
              : 'Opening portfolio…';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );

    final james = Builder(
      builder: (context) => ProfileCardWidget(
        name: 'James Okafor',
        role: 'Senior Flutter Engineer',
        details: const [
          {'label': 'Email', 'value': 'james@genui.dev'},
          {'label': 'GitHub', 'value': 'github.com/jokafor'},
          {'label': 'Joined', 'value': 'March 2022'},
        ],
        actions: const [
          {'label': 'Message', 'event': 'message'},
          {'label': 'Follow', 'event': 'follow'},
        ],
        dispatchEvent: (event) {
          final msg = event == 'message'
              ? 'Opening message thread with James…'
              : 'Following James Okafor!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: marie),
          const SizedBox(width: 16),
          Expanded(child: james),
        ],
      );
    }

    return Column(
      children: [
        marie,
        const SizedBox(height: 16),
        james,
      ],
    );
  }
}
