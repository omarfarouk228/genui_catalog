import 'package:flutter/material.dart';
import 'package:genui_catalog_example/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart' show AppShellState;
import '../services/api_key_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(onRefresh: () => setState(() {})),
            const SizedBox(height: 16),
            _ComponentGridSection(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero section
// ---------------------------------------------------------------------------

class _HeroSection extends StatefulWidget {
  final VoidCallback onRefresh;
  const _HeroSection({required this.onRefresh});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  final _keyController = TextEditingController();
  bool _editing = false;
  bool _obscure = true;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _saveKey() {
    final key = _keyController.text.trim();
    if (key.isNotEmpty) {
      ApiKeyProvider.set(key);
      setState(() => _editing = false);
      _keyController.clear();
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.5),
            colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Flutter · v0.2.0 · MIT License',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'GenUI Catalog',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -1.2,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                '17 production-ready components for AI-generated Flutter UIs.\nSchema-defined, event-driven, plug-and-play.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // CTA Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => launchUrl(Uri.parse(pubUrl)),
                    icon: const Icon(Icons.public, size: 18),
                    label: const Text('View on pub.dev'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(githubUrl)),
                    icon: const Icon(Icons.code, size: 18),
                    label: const Text('GitHub'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Catalog chips
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _CatalogChip(
                    label: 'DataCatalog',
                    color: Color(0xFF2196F3),
                    icon: Icons.bar_chart,
                  ),
                  _CatalogChip(
                    label: 'WorkflowCatalog',
                    color: Color(0xFFFF9800),
                    icon: Icons.account_tree,
                  ),
                  _CatalogChip(
                    label: 'FormCatalog',
                    color: Color(0xFF4CAF50),
                    icon: Icons.dynamic_form,
                  ),
                  _CatalogChip(
                    label: 'MediaCatalog',
                    color: Color(0xFF9C27B0),
                    icon: Icons.photo_library,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // API Key banner
              _ApiKeyBanner(
                editing: _editing,
                keyController: _keyController,
                obscure: _obscure,
                onToggleEdit: () => setState(() {
                  _editing = !_editing;
                  if (_editing) _keyController.clear();
                }),
                onToggleObscure: () => setState(() => _obscure = !_obscure),
                onSave: _saveKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiKeyBanner extends StatelessWidget {
  final bool editing;
  final TextEditingController keyController;
  final bool obscure;
  final VoidCallback onToggleEdit;
  final VoidCallback onToggleObscure;
  final VoidCallback onSave;

  const _ApiKeyBanner({
    required this.editing,
    required this.keyController,
    required this.obscure,
    required this.onToggleEdit,
    required this.onToggleObscure,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasKey = ApiKeyProvider.hasKey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasKey
            ? Colors.green.withValues(alpha: 0.08)
            : colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasKey
              ? Colors.green.withValues(alpha: 0.3)
              : colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: editing
          ? Row(
              children: [
                const Icon(Icons.vpn_key, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: keyController,
                    obscureText: obscure,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Paste your Gemini API key…',
                      isDense: true,
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                          size: 18,
                        ),
                        onPressed: onToggleObscure,
                      ),
                    ),
                    onSubmitted: (_) => onSave(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: onSave, child: const Text('Save')),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: onToggleEdit,
                  child: const Text('Cancel'),
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  hasKey ? Icons.check_circle : Icons.warning_amber_rounded,
                  size: 18,
                  color: hasKey ? Colors.green : colorScheme.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasKey
                        ? 'Gemini API key configured — all demo screens are active.'
                        : 'Add your Gemini API key to enable the interactive demos.',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasKey
                          ? Colors.green.shade700
                          : colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onToggleEdit,
                  child: Text(hasKey ? 'Change' : 'Add key'),
                ),
              ],
            ),
    );
  }
}

class _CatalogChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CatalogChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Component grid
// ---------------------------------------------------------------------------

class _ComponentGridSection extends StatelessWidget {
  const _ComponentGridSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'All Components',
                count: _allComponents.length,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _allComponents
                    .map((def) => _ComponentCard(def: def))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Component definition model
// ---------------------------------------------------------------------------

class _ComponentInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int navIndex;

  const _ComponentInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.navIndex,
  });
}

const Color _dataColor = Color(0xFF2196F3);
const Color _workflowColor = Color(0xFFFF9800);
const Color _formColor = Color(0xFF4CAF50);
const Color _mediaColor = Color(0xFF9C27B0);

const List<_ComponentInfo> _allComponents = [
  _ComponentInfo(
    name: 'KpiCard',
    description: 'Single metric with trend badge',
    icon: Icons.trending_up,
    color: _dataColor,
    navIndex: 2,
  ),
  _ComponentInfo(
    name: 'DataTable',
    description: 'Tabular data, up to 100 rows',
    icon: Icons.table_chart_outlined,
    color: _dataColor,
    navIndex: 2,
  ),
  _ComponentInfo(
    name: 'ChartCard',
    description: 'Line, Bar, or Pie chart',
    icon: Icons.insert_chart_outlined,
    color: _dataColor,
    navIndex: 2,
  ),
  _ComponentInfo(
    name: 'StatRow',
    description: '2–4 side-by-side stats',
    icon: Icons.space_bar,
    color: _dataColor,
    navIndex: 2,
  ),
  _ComponentInfo(
    name: 'ListCard',
    description: 'Tappable list rows in a card',
    icon: Icons.list_alt_outlined,
    color: _dataColor,
    navIndex: 2,
  ),
  _ComponentInfo(
    name: 'EmptyState',
    description: 'Empty view with optional CTA',
    icon: Icons.inbox_outlined,
    color: _dataColor,
    navIndex: 2,
  ),
  _ComponentInfo(
    name: 'TimelineCard',
    description: 'Vertical event timeline',
    icon: Icons.timeline,
    color: _workflowColor,
    navIndex: 3,
  ),
  _ComponentInfo(
    name: 'StatusBadge',
    description: 'Colored status indicator',
    icon: Icons.label_outline,
    color: _workflowColor,
    navIndex: 3,
  ),
  _ComponentInfo(
    name: 'StepperCard',
    description: 'Multi-step process navigator',
    icon: Icons.stairs_outlined,
    color: _workflowColor,
    navIndex: 3,
  ),
  _ComponentInfo(
    name: 'ActionForm',
    description: 'Dynamic form with submit',
    icon: Icons.edit_note_outlined,
    color: _formColor,
    navIndex: 4,
  ),
  _ComponentInfo(
    name: 'SearchBar',
    description: 'Debounced search input',
    icon: Icons.search,
    color: _formColor,
    navIndex: 4,
  ),
  _ComponentInfo(
    name: 'RatingInput',
    description: 'Star rating widget',
    icon: Icons.star_half,
    color: _formColor,
    navIndex: 4,
  ),
  _ComponentInfo(
    name: 'SelectInput',
    description: 'Dropdown single-value picker',
    icon: Icons.arrow_drop_down_circle_outlined,
    color: _formColor,
    navIndex: 4,
  ),
  _ComponentInfo(
    name: 'CheckboxGroup',
    description: 'Multi-select checkboxes',
    icon: Icons.check_box_outlined,
    color: _formColor,
    navIndex: 4,
  ),
  _ComponentInfo(
    name: 'SwitchGroup',
    description: 'List of on/off toggles',
    icon: Icons.toggle_on_outlined,
    color: _formColor,
    navIndex: 4,
  ),
  _ComponentInfo(
    name: 'ProfileCard',
    description: 'Avatar, details, and actions',
    icon: Icons.person_outline,
    color: _mediaColor,
    navIndex: 5,
  ),
  _ComponentInfo(
    name: 'MediaCard',
    description: 'Image, content, and tags',
    icon: Icons.image_outlined,
    color: _mediaColor,
    navIndex: 5,
  ),
];

// ---------------------------------------------------------------------------
// Component card widget
// ---------------------------------------------------------------------------

class _ComponentCard extends StatelessWidget {
  final _ComponentInfo def;

  const _ComponentCard({required this.def});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth;
    if (screenWidth >= 900) {
      cardWidth = ((1000 - 48 - 24) / 3).floorToDouble();
    } else if (screenWidth >= 600) {
      cardWidth = ((screenWidth - 48 - 12) / 2).floorToDouble();
    } else {
      cardWidth = screenWidth - 48;
    }
    cardWidth = cardWidth.clamp(240.0, 380.0);

    return SizedBox(
      width: cardWidth,
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            final shellState = context.findAncestorStateOfType<AppShellState>();
            shellState?.navigateTo(def.navIndex);
          },
          borderRadius: BorderRadius.circular(12),
          hoverColor: def.color.withValues(alpha: 0.04),
          splashColor: def.color.withValues(alpha: 0.08),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: def.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(def.icon, color: def.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        def.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
