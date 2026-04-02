import 'package:flutter/material.dart';

/// Parses a hex color string like "#2196F3" or "2196F3" into a [Color].
/// Returns [Colors.blue] as fallback if parsing fails.
Color parseHexColor(String hexStr) {
  try {
    final cleaned = hexStr.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    } else if (cleaned.length == 8) {
      return Color(int.parse(cleaned, radix: 16));
    }
  } catch (_) {}
  return Colors.blue;
}
