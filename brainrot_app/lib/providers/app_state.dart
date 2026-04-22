import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final List<TransactionItem> _recentActivity = [
    TransactionItem(
      title: 'Dopamine Tax',
      subtitle: 'TikTok unlock',
      amount: 2.00,
      date: 'Today',
      isPositive: false,
    ),
    TransactionItem(
      title: 'Deposit',
      subtitle: 'Apple Pay',
      amount: 10.00,
      date: 'Yesterday',
      isPositive: true,
    ),
    TransactionItem(
      title: 'Dopamine Tax',
      subtitle: 'Instagram unlock',
      amount: 2.00,
      date: 'Monday',
      isPositive: false,
    ),
  ];

  double get walletBalance => _walletBalance;
  bool get isUnlockedForToday => _isUnlockedForToday;
  int get dailyAllowanceMins => _dailyAllowanceMins;
  int get timeUsedMins => _timeUsedMins;
  List<TransactionItem> get recentActivity => _recentActivity;

  double get totalTaxPaid {
    return _recentActivity
        .where((t) => !t.isPositive)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> payTax() async {
    if (_walletBalance >= 2.00) {
      _walletBalance -= 2.00;
      _isUnlockedForToday = true;
      _recentActivity.insert(
        0,
        TransactionItem(
          title: 'Dopamine Tax',
          subtitle: 'Daily Universal Unlock',
          amount: 2.00,
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
