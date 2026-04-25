import 'package:intl/intl.dart';

/// Handles dynamic localized pricing with smart rounding.
///
/// Uses a base price in EUR and mock exchange rates to calculate
/// region-appropriate tax amounts. Smart rounding ensures prices
/// feel "natural" in each currency (e.g., ¥100 not ¥98.37).
class PricingService {
  PricingService._();

  /// Base daily tax price in EUR.
  static const double basePriceEur = 0.50;

  /// Mock exchange rates from EUR to target currency.
  static const Map<String, double> _rates = {
    'EUR': 1.0,
    'USD': 1.08,
    'GBP': 0.85,
    'RON': 4.97,
    'AUD': 1.65,
    'JPY': 160.0,
  };

  /// Currencies where values are large enough to round to nearest 10/50.
  static const Set<String> _largeCurrencies = {'JPY', 'KRW', 'VND'};

  /// Calculate the localized price for a given [currencyCode].
  ///
  /// Applies smart rounding:
  /// - Large-value currencies (JPY, KRW, VND): round to nearest 50.
  /// - Standard currencies (USD, EUR, GBP, RON, etc.): round to nearest 0.50.
  static double calculateLocalPrice(String currencyCode) {
    final rate = _rates[currencyCode] ?? 1.0;
    final rawPrice = basePriceEur * rate;

    if (_largeCurrencies.contains(currencyCode)) {
      // Round to nearest 50 (e.g., 80 → 100, 63 → 50)
      return (rawPrice / 50).round() * 50.0;
    }

    // Round to nearest 0.50 (e.g., 0.54 → 0.50, 0.78 → 1.00)
    return (rawPrice * 2).round() / 2.0;
  }

  /// Returns the native currency symbol for a given ISO 4217 [currencyCode].
  ///
  /// Uses the `intl` package's `NumberFormat.simpleCurrency`.
  /// Falls back to the code itself if no symbol is found.
  static String getCurrencySymbol(String currencyCode) {
    try {
      return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
    } catch (_) {
      return currencyCode;
    }
  }

  /// Formats a [value] as a currency string with the proper symbol.
  ///
  /// For large-value currencies, no decimal places are shown.
  /// For standard currencies, two decimal places are used.
  static String formatPrice(double value, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    if (_largeCurrencies.contains(currencyCode)) {
      return '$symbol${value.toStringAsFixed(0)}';
    }
    return '$symbol${value.toStringAsFixed(2)}';
  }
}
