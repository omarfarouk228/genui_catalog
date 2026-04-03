import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/utils/icon_utils.dart';

void main() {
  group('parseIconName', () {
    test('maps known icon names', () {
      expect(parseIconName('trending_up'), equals(Icons.trending_up));
      expect(parseIconName('people'), equals(Icons.people));
      expect(parseIconName('attach_money'), equals(Icons.attach_money));
      expect(parseIconName('star'), equals(Icons.star));
      expect(parseIconName('settings'), equals(Icons.settings));
    });

    test('maps aliases', () {
      expect(parseIconName('users'), equals(Icons.people));
      expect(parseIconName('dollar'), equals(Icons.attach_money));
      expect(parseIconName('like'), equals(Icons.thumb_up));
      expect(parseIconName('heart'), equals(Icons.favorite));
      expect(parseIconName('clock'), equals(Icons.access_time));
    });

    test('is case-insensitive', () {
      expect(parseIconName('STAR'), equals(Icons.star));
      expect(parseIconName('People'), equals(Icons.people));
    });

    test('strips whitespace', () {
      expect(parseIconName('  star  '), equals(Icons.star));
    });

    test('returns fallback for unknown icon', () {
      expect(parseIconName('totally_unknown_icon_xyz'), equals(Icons.label_outline));
    });

    test('returns fallback for empty string', () {
      expect(parseIconName(''), equals(Icons.label_outline));
    });
  });
}
