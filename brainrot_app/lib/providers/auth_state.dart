import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../services/auth_service.dart';
import '../services/profile_service.dart';

/// Auth state provider that listens to Supabase auth changes
/// and drives the app's routing (auth gate).
class AuthState extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<supa.AuthState>? _authSubscription;

  AuthState() {
    _init();
  }

  void _init() {
    // Check initial session.
    _isAuthenticated = AuthService.currentUser != null;

    // Listen for auth state changes (sign in, sign out, token refresh).
    _authSubscription = supa.Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final isNowAuth = data.session != null;
        if (isNowAuth != _isAuthenticated) {
          _isAuthenticated = isNowAuth;
          notifyListeners();
        }
      },
    );
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Sign in with email/password. Returns `true` on success.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.signIn(email: email, password: password);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on supa.AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email/password. Returns `true` on success.
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.signUp(
        email: email,
        password: password,
      );
      // Some Supabase projects require email confirmation.
      // If a session is returned, the user is authenticated immediately.
      _isAuthenticated = response.session != null;
      _isLoading = false;
      _errorMessage = _isAuthenticated
          ? null
          : 'Check your email to confirm your account.';
      
      if (response.user != null) {
        // Attempt to create the initial profile row. We don't block auth state if it fails,
        // but it's important for the wallet balance feature.
        try {
          await ProfileService.createProfile(response.user!.id, email);
        } catch (_) {
          // Profile might already exist or trigger might have handled it, ignore for MVP.
        }
      }
      
      notifyListeners();
      return _isAuthenticated;
    } on supa.AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await AuthService.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Clear any displayed error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
