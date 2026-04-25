import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pricing_service.dart';

class TransactionItem {
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final bool isPositive;

  TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isPositive,
  });
}

class AppState extends ChangeNotifier {
  double _walletBalance = 10.00;
  bool _isUnlockedForToday = false;
  final int _dailyAllowanceMins = 60;
  int _timeUsedMins = 60;

  // ── Tracked Apps ─────────────────────────────────────────────────────────
  final Map<String, bool> _trackedApps = {
    'TikTok': true,
    'Instagram': true,
    'YouTube': true,
  };

  // ── Localized pricing ────────────────────────────────────────────────────
  String _currencyCode = 'USD';
  String _currencySymbol = '\$';
  double _taxAmount = 0.50;

  AppState() {
    _initLocale();
  }

  /// Detect the device locale and set currency accordingly.
  void _initLocale() {
    // Attempt to derive currency from platform locale.
    // Falls back to USD for unknown / unsupported regions.
    final String localeTag = Platform.localeName; // e.g. "en_US", "ro_RO"
    final parts = localeTag.split('_');
    final countryCode = parts.length >= 2 ? parts.last.toUpperCase() : '';

    _currencyCode = _countryToCurrency(countryCode);
    _currencySymbol = PricingService.getCurrencySymbol(_currencyCode);
    _taxAmount = PricingService.calculateLocalPrice(_currencyCode);

    // Scale the initial mock wallet balance to ~20× tax for usability.
    _walletBalance = _taxAmount * 20;

    // Update mock transaction amounts to use localized pricing.
    _recentActivity.clear();
    _recentActivity.addAll([
      TransactionItem(
        title: 'Dopamine Tax',
        subtitle: 'TikTok unlock',
        amount: _taxAmount,
        date: 'Today',
        isPositive: false,
      ),
      TransactionItem(
        title: 'Deposit',
        subtitle: 'Apple Pay',
        amount: _taxAmount * 20,
        date: 'Yesterday',
        isPositive: true,
      ),
      TransactionItem(
        title: 'Dopamine Tax',
        subtitle: 'Instagram unlock',
        amount: _taxAmount,
        date: 'Monday',
        isPositive: false,
      ),
    ]);
  }

  /// Maps ISO 3166 country code to ISO 4217 currency code.
  String _countryToCurrency(String country) {
    const map = {
      'US': 'USD',
      'GB': 'GBP',
      'AU': 'AUD',
      'RO': 'RON',
      'JP': 'JPY',
      // Eurozone
      'DE': 'EUR', 'FR': 'EUR', 'ES': 'EUR', 'IT': 'EUR',
      'NL': 'EUR', 'BE': 'EUR', 'AT': 'EUR', 'PT': 'EUR',
      'IE': 'EUR', 'FI': 'EUR', 'GR': 'EUR',
    };
    return map[country] ?? 'USD';
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  final List<TransactionItem> _recentActivity = [];

  double get walletBalance => _walletBalance;
  bool get isUnlockedForToday => _isUnlockedForToday;
  int get dailyAllowanceMins => _dailyAllowanceMins;
  int get timeUsedMins => _timeUsedMins;
  Map<String, bool> get trackedApps => _trackedApps;
  List<TransactionItem> get recentActivity => _recentActivity;

  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  double get taxAmount => _taxAmount;

  double get totalTaxPaid {
    return _recentActivity
        .where((t) => !t.isPositive)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Format a value using the user's local currency.
  String formatPrice(double value) {
    return PricingService.formatPrice(value, _currencyCode);
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void toggleAppTracking(String appName, bool isTracked) {
    if (_trackedApps.containsKey(appName)) {
      _trackedApps[appName] = isTracked;
      notifyListeners();
      // TODO: Persist and sync to native Kotlin side
    }
  }

  Future<void> payTax() async {
    if (_walletBalance >= _taxAmount) {
      _walletBalance -= _taxAmount;
      _isUnlockedForToday = true;
      _recentActivity.insert(
        0,
        TransactionItem(
          title: 'Dopamine Tax',
          subtitle: 'Daily Universal Unlock',
          amount: _taxAmount,
          date: 'Just now',
          isPositive: false,
        ),
      );
      notifyListeners();

      // Persist unlock state so the Kotlin AccessibilityService can read it
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isUnlockedForToday", true);
    }
  }

  void addFunds(double amount) {
    _walletBalance += amount;
    _recentActivity.insert(
      0,
      TransactionItem(
        title: 'Deposit',
        subtitle: 'Quick Top-Up',
        amount: amount,
        date: 'Just now',
        isPositive: true,
      ),
    );
    notifyListeners();
  }

  Future<void> resetDebugState() async {
    _isUnlockedForToday = false;
    _timeUsedMins = 60;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isUnlockedForToday", false);
  }
}
