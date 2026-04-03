import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_catalog/src/utils/color_utils.dart';

void main() {
  group('parseHexColor', () {
    test('parses 6-char hex without #', () {
      expect(parseHexColor('2196F3'), equals(const Color(0xFF2196F3)));
    });

    test('parses 6-char hex with #', () {
      expect(parseHexColor('#FF5722'), equals(const Color(0xFFFF5722)));
    });

    test('parses 8-char hex with alpha', () {
      expect(parseHexColor('80FF5722'), equals(const Color(0x80FF5722)));
    });

    test('returns fallback for invalid hex', () {
      expect(parseHexColor('GGGGGG'), equals(Colors.blue));
    });

    test('returns custom fallback for invalid hex', () {
      expect(parseHexColor('ZZZ', fallback: Colors.red), equals(Colors.red));
    });

    test('returns fallback for empty string', () {
      expect(parseHexColor(''), equals(Colors.blue));
    });

    test('returns fallback for wrong length', () {
      expect(parseHexColor('12345'), equals(Colors.blue));
    });
  });
}
