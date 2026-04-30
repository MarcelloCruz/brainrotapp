import 'package:supabase_flutter/supabase_flutter.dart';

/// Service layer for all Supabase authentication operations.
///
/// Keeps Supabase API calls out of UI widgets per project rules
/// (strict UI ↔ Logic separation).
class AuthService {
  AuthService._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// The currently authenticated user, or `null` if signed out.
  static User? get currentUser => _client.auth.currentUser;

  /// A live stream of auth state changes (sign in, sign out, token refresh).
  static Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  /// Sign in with email and password.
  ///
  /// Returns the [AuthResponse] on success; throws [AuthException] on failure.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Create a new account with email and password.
  ///
  /// Returns the [AuthResponse] on success; throws [AuthException] on failure.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
