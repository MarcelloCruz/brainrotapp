import 'package:supabase_flutter/supabase_flutter.dart';

/// Service layer for database operations on the 'profiles' table.
///
/// Keeps Supabase database calls cleanly separated from the UI widgets.
class ProfileService {
  ProfileService._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// Creates a new profile row for a newly registered user.
  static Future<void> createProfile(String uid, String email) async {
    await _client.from('profiles').insert({
      'id': uid,
      'email': email,
      'wallet_balance': 0.00,
    });
  }

  /// Fetches the profile data containing wallet_balance and is_dev.
  /// If the profile doesn't exist, automatically creates it to prevent PGRST116 errors.
  static Future<Map<String, dynamic>> fetchProfileData(String uid) async {
    final response = await _client
        .from('profiles')
        .select('wallet_balance, is_dev')
        .eq('id', uid)
        .maybeSingle();
        
    if (response == null) {
      final email = _client.auth.currentUser?.email ?? '';
      await createProfile(uid, email);
      return {
        'wallet_balance': 0.00,
        'is_dev': false,
      };
    }

    return {
      'wallet_balance': (response['wallet_balance'] as num).toDouble(),
      'is_dev': response['is_dev'] as bool? ?? false,
    };
  }

  /// Deducts the specified amount from the user's wallet balance.
  /// Uses a read-then-update approach. Returns true if successful, false if insufficient funds.
  static Future<bool> deductTax(String uid, double amount) async {
    final data = await fetchProfileData(uid);
    final currentBalance = data['wallet_balance'] as double;
    if (currentBalance >= amount) {
      final newBalance = currentBalance - amount;
      await _client
          .from('profiles')
          .update({'wallet_balance': newBalance})
          .eq('id', uid);
      return true;
    }
    return false;
  }

  /// Manually set the wallet balance (for God Mode testing).
  static Future<void> setWalletBalance(String uid, double amount) async {
    await _client
        .from('profiles')
        .update({'wallet_balance': amount})
        .eq('id', uid);
  }

  /// Adds the specified amount to the user's wallet balance.
  /// Used after a successful Stripe top-up payment.
  static Future<double> addFundsToWallet(String uid, double amount) async {
    final data = await fetchProfileData(uid);
    final currentBalance = data['wallet_balance'] as double;
    final newBalance = currentBalance + amount;
    await _client
        .from('profiles')
        .update({'wallet_balance': newBalance})
        .eq('id', uid);
    return newBalance;
  }
}
