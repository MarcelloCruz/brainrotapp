import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/native_bridge.dart';

/// Full-screen onboarding screen that guides the user through granting
/// the two required Android permissions:
///   1. SYSTEM_ALERT_WINDOW — "Display over other apps"
///   2. BIND_ACCESSIBILITY_SERVICE — "Doomscroll Tracker"
///
/// Matches the premium dark/glassmorphic aesthetic.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _hasOverlay = false;
  bool _hasAccessibility = false;

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

  /// Re-check permissions every time the user returns from Settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final overlay = await NativeBridge.checkOverlayPermission();
    final accessibility = await NativeBridge.checkAccessibilityPermission();

    if (!mounted) return;

    setState(() {
      _hasOverlay = overlay;
      _hasAccessibility = accessibility;
    });

    // If both granted, the _AuthGate in main.dart will automatically
    // re-evaluate and route to HomeScreen on the next frame.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF151522), Color(0xFF0D0D16)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // ── Shield icon ──
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.shield_lefthalf_fill,
                    color: Color(0xFF1D4ED8),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Title ──
                Text(
                  'Setup\nRequired',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1.05,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dopamine Tax needs two permissions to monitor and block doomscrolling apps.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 48),

                // ── Step 1: Overlay Permission ──
                _PermissionStep(
                  stepNumber: 1,
                  title: 'Display Over Apps',
                  description:
                      'Allows the frosted-glass block overlay to appear on top of TikTok when your limit is reached.',
                  isGranted: _hasOverlay,
                  onTap: _hasOverlay
                      ? null
                      : () => NativeBridge.openOverlaySettings(),
                ),
                const SizedBox(height: 20),

                // ── Step 2: Accessibility Service ──
                _PermissionStep(
                  stepNumber: 2,
                  title: 'Enable Doomscroll Tracker',
                  description:
                      'To detect when you open TikTok, we need accessibility access. We never read your screen content.',
                  isGranted: _hasAccessibility,
                  onTap: _hasAccessibility
                      ? null
                      : () => NativeBridge.openAccessibilitySettings(),
                ),

                const Spacer(),

                // ── Bottom status ──
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _hasOverlay && _hasAccessibility
                          ? Column(
                              key: const ValueKey('granted'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  color: Colors.greenAccent,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'All set! Loading dashboard…',
                                  style: TextStyle(
                                    color: Colors.greenAccent.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              key: const ValueKey('pending'),
                              'Grant both permissions to continue',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single permission step card with a number badge, description,
/// and a grant/granted indicator.
class _PermissionStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback? onTap;

  const _PermissionStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.isGranted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isGranted ? Colors.greenAccent : const Color(0xFF1D4ED8);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isGranted
                  ? Colors.greenAccent.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isGranted
                    ? Colors.greenAccent.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                // ── Step number badge ──
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: isGranted
                        ? Icon(
                            CupertinoIcons.checkmark_alt,
                            color: accentColor,
                            size: 20,
                          )
                        : Text(
                            '$stepNumber',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // ── Grant / Granted indicator ──
                isGranted
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'Granted',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Icon(
                        CupertinoIcons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 18,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
