import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/shared/formatting/format_minor_price.dart';

void main() {
  group('formatMinorPrice', () {
    test('formats minor units as Rs with two decimals and thousands grouping', () {
      expect(formatMinorPrice(200000), 'Rs 2,000.00');
      expect(formatMinorPrice(100), 'Rs 1.00');
      expect(formatMinorPrice(1), 'Rs 0.01');
    });

    test('handles zero', () {
      expect(formatMinorPrice(0), 'Rs 0.00');
    });
  });
}