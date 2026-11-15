import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class CurrencyFormatter {
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;
    final fromRate = AppConstants.usdExchangeRates[fromCurrency] ?? 1.0;
    final toRate = AppConstants.usdExchangeRates[toCurrency] ?? 1.0;

    // Convert to USD base first
    final amountInUsd = amount / fromRate;
    // Then convert to target currency
    return amountInUsd * toRate;
  }

  static String format(double amount, String currencyCode) {
    final symbol = getSymbol(currencyCode);
    final numberFormat = NumberFormat('#,##0.00', 'en_US');
    if (currencyCode == 'JPY') {
      final jpyFormat = NumberFormat('#,##0', 'en_US');
      return '$symbol${jpyFormat.format(amount)}';
    }
    return '$symbol${numberFormat.format(amount)}';
  }

  static String getSymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'PKR':
        return 'PKR ';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      case 'AED':
        return 'AED ';
      default:
        return '$currencyCode ';
    }
  }
}
