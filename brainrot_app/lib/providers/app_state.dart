import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/native_bridge.dart';
import '../services/pricing_service.dart';
import '../services/profile_service.dart';

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
  bool _isDev = false;
  final int _dailyAllowanceMins = 60;
  int _timeUsedMins = 0;
  Timer? _liveSyncTimer;

  // ── Tracked Apps ─────────────────────────────────────────────────────────
  // MVP: TikTok only.
  final Map<String, bool> _trackedApps = {
    'TikTok': true,
  };

  // ── Localized pricing ────────────────────────────────────────────────────
  String _currencyCode = 'USD';
  String _currencySymbol = '\$';
  double _taxAmount = 0.50;

  AppState() {
    _initLocale();
    _listenToAuth();
  }

  void _listenToAuth() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (data.session != null) {
        try {
          final profile = await ProfileService.fetchProfileData(data.session!.user.id);
          _walletBalance = profile['wallet_balance'] as double;
          _isDev = profile['is_dev'] as bool;
          notifyListeners();
        } catch (e) {
          // Fallback or handle error
          debugPrint('Error fetching profile data: $e');
        }
      } else {
        // User logged out, reset balance and tracking state for safety.
        _walletBalance = 0.0;
        _isDev = false;
        _timeUsedMins = 0;
        _isUnlockedForToday = false;
        notifyListeners();
        
        // Also clear native persisted state to stop timers across logins
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("timeUsedMins", 0);
        await prefs.setBool("isUnlockedForToday", false);
        await NativeBridge.setUsageTime(0);
      }
    });
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

    // Seed mock transaction history with localized amounts.
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
  bool get isTaxPaid => _isUnlockedForToday;
  bool get isDev => _isDev;
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

  // ── Persistence ─────────────────────────────────────────────────────────

  /// Load persisted state from SharedPreferences.
  ///
  /// Called once from main.dart on app startup to hydrate unlock status
  /// and accumulated usage time so state survives app restarts.
  Future<void> loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    _isUnlockedForToday = prefs.getBool("isUnlockedForToday") ?? false;
    _timeUsedMins = prefs.getInt("timeUsedMins") ?? 0;
    notifyListeners();
  }

  /// Pull the latest accumulated usage time from the native layer.
  ///
  /// Uses [NativeBridge.getUsageTime] which reads directly from Android
  /// SharedPreferences via MethodChannel, bypassing Flutter's stale cache.
  Future<void> syncTimeFromNative() async {
    final nativeTime = await NativeBridge.getUsageTime();
    if (nativeTime != _timeUsedMins) {
      _timeUsedMins = nativeTime;
      notifyListeners();
    }
  }

  /// Start a periodic timer that polls the native layer for live usage time.
  ///
  /// Called when the Flutter app enters the foreground so the dashboard
  /// progress bar updates in real-time.
  void startLiveSync() {
    _liveSyncTimer?.cancel();
    // Immediately sync once, then every 2 seconds.
    syncTimeFromNative();
    _liveSyncTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => syncTimeFromNative(),
    );
  }

  /// Stop the periodic polling timer.
  ///
  /// Called when the Flutter app goes to the background to avoid
  /// unnecessary MethodChannel calls.
  void stopLiveSync() {
    _liveSyncTimer?.cancel();
    _liveSyncTimer = null;
  }

  /// Update usage time from a value pushed by the native side.
  void updateTimeUsed(int minutes) {
    if (minutes != _timeUsedMins) {
      _timeUsedMins = minutes;
      notifyListeners();
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void toggleAppTracking(String appName, bool isTracked) {
    if (_trackedApps.containsKey(appName)) {
      _trackedApps[appName] = isTracked;
      notifyListeners();
      // TODO: Persist and sync to native Kotlin side
    }
  }

  Future<bool> payTax() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    if (_walletBalance >= _taxAmount) {
      try {
        final success = await ProfileService.deductTax(user.id, _taxAmount);
        if (success) {
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
          return true;
        }
      } catch (e) {
        debugPrint('Error deducting tax: $e');
        return false;
      }
    }
    return false;
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

  /// Credits the wallet after a successful Stripe top-up.
  ///
  /// Updates the Supabase `profiles` table and refreshes local state.
  Future<bool> topUpWallet(double amount) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    try {
      final newBalance = await ProfileService.addFundsToWallet(user.id, amount);
      _walletBalance = newBalance;
      _recentActivity.insert(
        0,
        TransactionItem(
          title: 'Top Up',
          subtitle: 'Stripe Payment',
          amount: amount,
          date: 'Just now',
          isPositive: true,
        ),
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error topping up wallet: $e');
      return false;
    }
  }

  Future<void> resetDebugState() async {
    _isUnlockedForToday = false;
    _timeUsedMins = 0;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isUnlockedForToday", false);
    await prefs.setInt("timeUsedMins", 0);
  }

  // ── God Mode (Testing) ───────────────────────────────────────────────────

  /// Instantly resets or sets the Supabase wallet balance.
  Future<void> setWalletBalance(double amount) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await ProfileService.setWalletBalance(user.id, amount);
      _walletBalance = amount;
      notifyListeners();
    }
  }

  /// Manually overrides the time used, pushing it to the native service so the block triggers.
  Future<void> setDebugTimeUsed(int minutes) async {
    _timeUsedMins = minutes;
    notifyListeners();
    await NativeBridge.setUsageTime(minutes);
  }

  /// Instantly flips the paid state for God Mode testing.
  Future<void> toggleDebugPaidState() async {
    _isUnlockedForToday = !_isUnlockedForToday;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isUnlockedForToday", _isUnlockedForToday);
  }
}
