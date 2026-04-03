import 'package:flutter/material.dart';

/// Parses a hex color string like "#2196F3" or "2196F3" into a [Color].
/// Returns [fallback] if parsing fails (defaults to [Colors.blue]).
/// Callers with a [BuildContext] should pass `Theme.of(context).colorScheme.primary`
/// as [fallback] to stay theme-aware.
Color parseHexColor(String hexStr, {Color fallback = Colors.blue}) {
  try {
    final cleaned = hexStr.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    } else if (cleaned.length == 8) {
      return Color(int.parse(cleaned, radix: 16));
    }
  } catch (_) {}
  return fallback;
}
