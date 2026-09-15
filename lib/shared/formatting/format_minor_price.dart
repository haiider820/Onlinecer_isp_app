import 'package:intl/intl.dart';

/// Default currency prefix for minor-unit prices (Pakistani Rupee).
///
/// The backend prices money in the smallest currency unit (`price_minor`,
/// e.g. `200000` for Rs 2,000.00), so amounts are divided by 100 for display.
const String currencySymbol = 'Rs';

/// Formats a minor-unit price as user-facing text.
///
///     formatMinorPrice(200000) => 'Rs 2,000.00'
String formatMinorPrice(int priceMinor) {
  final amount = priceMinor / 100;
  return '$currencySymbol ${NumberFormat('#,##0.00').format(amount)}';
}