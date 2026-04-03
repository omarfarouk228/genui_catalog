import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_catalog_example/models/preset.dart';
import '../services/ai_service.dart';
import '../services/api_key_provider.dart';

/// Reusable base for catalog demo screens.
///
/// Shows a header with catalog info, preset prompt chips, and an AI-generated
/// [Surface] that updates each time a preset is tapped.
class CatalogDemoScreen extends StatefulWidget {
  final String catalogName;
  final String subtitle;
  final int componentCount;
  final Color accentColor;
  final IconData icon;
  final List<Preset> presets;

  const CatalogDemoScreen({
    super.key,
    required this.catalogName,
    required this.subtitle,
    required this.componentCount,
    required this.accentColor,
    required this.icon,
    required this.presets,
  });

  @override
  State<CatalogDemoScreen> createState() => _CatalogDemoScreenState();
}

class _CatalogDemoScreenState extends State<CatalogDemoScreen> {
  AiService? _service;
  final List<String> _surfaceIds = [];
  int _selectedPreset = -1;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  void _initService() {
    if (!ApiKeyProvider.hasKey) return;
    _service?.dispose();
    _service = AiService(apiKey: ApiKeyProvider.key)
      ..onSurfaceAdded = (id) {
        if (mounted) setState(() => _surfaceIds.add(id));
      }
      ..onSurfaceRemoved = (id) {
        if (mounted) setState(() => _surfaceIds.remove(id));
      }
      ..onError = (e) {
        if (mounted) {
          setState(() {
            _error = e;
            _loading = false;
          });
        }
      };
  }

  Future<void> _runPreset(int index) async {
    if (_loading) return;
    if (!ApiKeyProvider.hasKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add your Gemini API key on the Home screen first.'),
        ),
      );
      return;
    }

    // Re-create service so each run starts from a clean surface list.
    setState(() {
      _surfaceIds.clear();
      _selectedPreset = index;
      _error = null;
      _loading = true;
    });
    _initService();

    final prompt = widget.presets[index].prompt;
    await _service!.send(prompt);
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _CatalogHeader(
                name: widget.catalogName,
                subtitle: widget.subtitle,
                componentCount: widget.componentCount,
                accentColor: widget.accentColor,
                icon: widget.icon,
              ),
            ),
          ),

          // ── Preset chips ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try a preset prompt',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(widget.presets.length, (i) {
                      final preset = widget.presets[i];
                      final selected = _selectedPreset == i;
                      return FilterChip(
                        label: Text(preset.label),
                        avatar: Icon(preset.icon, size: 16),
                        selected: selected,
                        onSelected: (_) => _runPreset(i),
                        selectedColor: widget.accentColor.withValues(
                          alpha: 0.15,
                        ),
                        checkmarkColor: widget.accentColor,
                        side: BorderSide(
                          color: selected
                              ? widget.accentColor.withValues(alpha: 0.6)
                              : colorScheme.outlineVariant,
                        ),
                        labelStyle: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selected
                              ? widget.accentColor
                              : colorScheme.onSurface,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // ── Surface area ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildSurfaceArea(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurfaceArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // No key configured
    if (!ApiKeyProvider.hasKey) {
      return _EmptyState(
        icon: Icons.vpn_key_outlined,
        title: 'API key required',
        subtitle:
            'Add your Gemini API key on the Home screen to enable the interactive demo.',
        accentColor: colorScheme.primary,
      );
    }

    // Error state
    if (_error != null) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: _error.toString(),
        accentColor: colorScheme.error,
      );
    }

    // Loading state
    if (_loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            children: [
              CircularProgressIndicator(color: widget.accentColor),
              const SizedBox(height: 16),
              Text(
                'Generating UI with Gemini…',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Idle — no preset selected yet
    if (_selectedPreset == -1) {
      return _EmptyState(
        icon: widget.icon,
        title: 'Select a preset above',
        subtitle:
            'Gemini will generate a live UI showcasing ${widget.catalogName} components.',
        accentColor: widget.accentColor,
      );
    }

    // No surfaces yet (shouldn't linger, but just in case)
    if (_surfaceIds.isEmpty) {
      return _EmptyState(
        icon: widget.icon,
        title: 'No surface generated yet',
        subtitle: 'Try tapping a preset chip above.',
        accentColor: widget.accentColor,
      );
    }

    // Render all surfaces
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Rendered by genui" label
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Rendered via genui · ${widget.catalogName}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._surfaceIds.map(
          (id) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Surface(surfaceContext: _service!.controller.contextFor(id)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _CatalogHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final int componentCount;
  final Color accentColor;
  final IconData icon;

  const _CatalogHeader({
    required this.name,
    required this.subtitle,
    required this.componentCount,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.1),
            accentColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$componentCount components',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: accentColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
