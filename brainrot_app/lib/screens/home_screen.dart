import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/native_bridge.dart';
import '../widgets/dashboard_card.dart';
import 'wallet_screen.dart';
import 'dev_panel.dart';
import 'profile_bottom_sheet.dart';


/// Minimalist home screen for Dopamine Tax.
///
/// Features a large typographic header, an accessibility-permission banner,
/// and a button that previews the frosted-glass "App Block" overlay.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _hasPermission = true; // optimistic default to avoid flash

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
    // Start polling native layer for live usage time updates.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().startLiveSync();
      _checkBlockTrigger();
    });
  }

  Future<void> _checkBlockTrigger() async {
    final appState = context.read<AppState>();
    final isBlocked = await NativeBridge.checkBlockTrigger();
    if (isBlocked && !appState.isTaxPaid) {
      if (mounted) {
        Navigator.of(context).pushNamed('/block');
        await NativeBridge.clearBlockTrigger();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check when user returns from system Settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
      // Resume live sync when app enters foreground.
      if (mounted) {
        context.read<AppState>().startLiveSync();
        _checkBlockTrigger();
      }
    } else if (state == AppLifecycleState.paused) {
      // Stop polling when app goes to background.
      context.read<AppState>().stopLiveSync();
    }
  }

  Future<void> _checkPermission() async {
    bool granted = false;
    if (Platform.isIOS) {
      granted = await NativeBridge.checkIOSScreenTimePermission();
    } else {
      granted = await NativeBridge.checkAccessibilityPermission();
    }
    if (mounted) setState(() => _hasPermission = granted);
  }

  // ── Block Overlay method removed ──

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Top Right Icons ──
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Profile / Account ──
                    IconButton(
                      icon: const Icon(Icons.account_circle_outlined, size: 28),
                      onPressed: () => ProfileBottomSheet.show(context),
                    ),
                    const SizedBox(width: 4),

                    // ── Wallet Icon ──
                    IconButton(
                      icon: const Icon(CupertinoIcons.creditcard, size: 28),
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const WalletScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),

                    // ── Dev Tools (God Mode) ──
                    Consumer<AppState>(
                      builder: (context, state, child) {
                        if (!state.isDev) return const SizedBox.shrink();
                        return IconButton(
                          icon: const Icon(Icons.terminal, size: 28, color: Colors.greenAccent),
                          onPressed: () => DevPanel.show(context),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Large header ──
              Text(
                'Dopamine\nTax',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 16),

              // ── Permission banner ──
              _hasPermission
                  ? _ShieldActivePill(isDark: isDark)
                  : _PermissionBanner(
                      isDark: isDark,
                      onTap: () async {
                        if (Platform.isIOS) {
                          final success = await NativeBridge.requestIOSScreenTimePermission();
                          if (success) {
                            _checkPermission();
                          }
                        } else {
                          NativeBridge.openAccessibilitySettings();
                        }
                      },
                    ),

              // ── Subtitle ──
              Text(
                'Take control of your attention.\nMake doomscrolling cost you.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 17,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 36),

              // ── Dashboard card ──
              const DashboardCard(),

              // ── Target Apps Header ──
              Text(
                'Target Apps',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // ── Target Apps List ──
              Platform.isIOS
                  ? const _IOSTargetAppsButton()
                  : const _TargetAppsList(),

              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission Banner
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionBanner extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _PermissionBanner({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_shield_fill,
            color: Colors.redAccent.shade100,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action Required',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enable App Monitor to block doomscrolling.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Enable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldActivePill extends StatelessWidget {
  final bool isDark;
  const _ShieldActivePill({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B3320) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.checkmark_shield_fill,
            color: isDark ? Colors.greenAccent : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Shield Active',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.greenAccent : Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetAppsList extends StatelessWidget {
  const _TargetAppsList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = context.watch<AppState>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: state.trackedApps.entries.map((entry) {
          final isLast = entry.key == state.trackedApps.keys.last;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoSwitch(
                      value: entry.value,
                      onChanged: (val) {
                        context.read<AppState>().toggleAppTracking(entry.key, val);
                      },
                      activeTrackColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _IOSTargetAppsButton extends StatelessWidget {
  const _IOSTargetAppsButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: () {
          NativeBridge.selectIOSAppsToBlock();
        },
        child: const Text(
          'Select Apps to Block',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
