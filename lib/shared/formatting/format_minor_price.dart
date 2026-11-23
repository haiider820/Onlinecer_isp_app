import 'package:intl/intl.dart';

/// Default currency prefix for minor-unit prices (Pakistani Rupee).
///
/// The backend prices money in the smallest currency unit (`price_minor`,
/// e.g. `200000` for Rs 2,000), so amounts are divided by 100 for display.
const String currencySymbol = 'Rs';

/// Formats a minor-unit price as user-facing text.
///
/// Whole-rupee amounts drop the decimals; fractional amounts keep two:
///
///     formatMinorPrice(200000) => 'Rs 2,000'
///     formatMinorPrice(100) => 'Rs 1'
///     formatMinorPrice(1) => 'Rs 0.01'
String formatMinorPrice(int priceMinor) {
  final amount = priceMinor / 100;
  final pattern = priceMinor % 100 == 0 ? '#,##0' : '#,##0.00';
  return '$currencySymbol ${NumberFormat(pattern).format(amount)}';
}
