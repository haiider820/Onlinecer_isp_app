import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/shared/formatting/format_minor_price.dart';

void main() {
  group('formatMinorPrice', () {
    test('formats minor units as Rs with thousands grouping, no decimals for whole rupees', () {
      expect(formatMinorPrice(200000), 'Rs 2,000');
      expect(formatMinorPrice(100), 'Rs 1');
      expect(formatMinorPrice(1), 'Rs 0.01');
    });

    test('handles zero', () {
      expect(formatMinorPrice(0), 'Rs 0');
    });
  });
}