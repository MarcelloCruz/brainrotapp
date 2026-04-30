import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'services/native_bridge.dart';
import 'screens/home_screen.dart';
import 'screens/overlay_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/permissions_screen.dart';
import 'providers/app_state.dart';
import 'providers/auth_state.dart' as app_auth;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Stripe ──────────────────────────────────────────────────
  // Replace with your real pk_test_... key before testing.
  Stripe.publishableKey =
      'pk_test_51QvdpUKpnw4YShQiyOAVyfvHkqxPXGB5J5hpww3VeKenNLmrMPFd1bPuEZiVKSRK56SzLDfAK4KvUAwGzhEetWSS00t8eRRBgy';

  // ── Initialize Supabase ────────────────────────────────────────────────
  await Supabase.initialize(
    url: 'https://ucyuziklrvpndbxihqlk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjeXV6aWtscnZwbmRieGlocWxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1NDE1MDMsImV4cCI6MjA5MzExNzUwM30.ooKliWSmIkp5tdLHf-wne-_uhx3jY7TraD9e0CpNnZg',
  );

  // Create AppState and hydrate persisted values before first frame.
  final appState = AppState();
  await appState.loadPersistedState();

  // Create AuthState after Supabase is initialized.
  final authState = app_auth.AuthState();

  NativeBridge.initialize(navigatorKey, appState, authState);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: authState),
      ],
      child: const DopamineTaxApp(),
    ),
  );
}

class DopamineTaxApp extends StatelessWidget {
  const DopamineTaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Dopamine Tax',
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const _AuthGate(),
        '/block': (context) => const OverlayScreen(),
      },
    );
  }
}

/// Auth + Permissions gate widget.
///
/// Routes:
///   - Not authenticated → [AuthScreen]
///   - Authenticated, missing permissions (Android only) → [PermissionsScreen]
///   - Authenticated, all permissions granted → [HomeScreen]
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> with WidgetsBindingObserver {
  bool _permissionsGranted = true; // optimistic default to avoid flash
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check permissions when returning from system Settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (!Platform.isAndroid) {
      // iOS permissions are handled differently; skip for now.
      if (mounted) setState(() { _permissionsGranted = true; _hasChecked = true; });
      return;
    }

    final overlay = await NativeBridge.checkOverlayPermission();
    final accessibility = await NativeBridge.checkAccessibilityPermission();

    if (mounted) {
      setState(() {
        _permissionsGranted = overlay && accessibility;
        _hasChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthState>();

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    // Wait until we've completed the first permissions check.
    if (!_hasChecked) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D16),
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (!_permissionsGranted) {
      return const PermissionsScreen();
    }

    return const HomeScreen();
  }
}

