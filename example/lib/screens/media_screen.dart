import 'package:flutter/material.dart';
import 'package:genui_catalog_example/models/preset.dart';
import '../widgets/catalog_demo_screen.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatalogDemoScreen(
      catalogName: 'MediaCatalog',
      subtitle: 'Profile cards, media displays, and image components.',
      componentCount: 2,
      accentColor: const Color(0xFFE91E63),
      icon: Icons.photo_library_rounded,
      presets: const [
        Preset(
          label: 'User Directory',
          icon: Icons.contacts_outlined,
          prompt:
              'Display a user directory with 3 ProfileCards showing name, role, '
              'and actions to "Message" and "View Profile" for a Developer, a Designer, and a Manager.',
        ),
        Preset(
          label: 'Content Feed',
          icon: Icons.feed_outlined,
          prompt:
              'Show a content feed with 2 MediaCards featuring an article image, title, '
              'description, and tags like "#Flutter" and "#GenUI", along with "Read More" actions.',
        ),
        Preset(
          label: 'Creator Profile',
          icon: Icons.account_circle_outlined,
          prompt:
              'Create a creator profile view showing their ProfileCard at the top, '
              'followed by 2 MediaCards representing their recent video uploads or articles.',
        ),
      ],
    );
  }
}
