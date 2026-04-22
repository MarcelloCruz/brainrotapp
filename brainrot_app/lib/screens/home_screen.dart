import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/native_bridge.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/frosted_glass_overlay.dart';
import '../widgets/premium_primary_button.dart';
import 'wallet_screen.dart';

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
    }
  }

  Future<void> _checkPermission() async {
    final granted = await NativeBridge.checkAccessibilityPermission();
    if (mounted) setState(() => _hasPermission = granted);
  }

  void _showBlockOverlay(BuildContext context) {
    final theme = Theme.of(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (context2, animation1, animation2) {
        return FrostedGlassOverlay(
          onDismiss: () => Navigator.of(context).pop(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Lock icon ──
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.lock_fill,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Title ──
                  Text(
                    'App Blocked',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Subtitle ──
                  Text(
                    'Daily limit (1h) reached.\nPay the tax or walk away.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Pay button (primary action) ──
                  SizedBox(
                    width: double.infinity,
                    child: PremiumPrimaryButton(
                      label: 'Pay \$2.00 (Unlocks till midnight)',
                      icon: CupertinoIcons.creditcard,
                      onPressed: () async {
                        final state = context.read<AppState>();
                        if (state.walletBalance >= 2.00) {
                          await state.payTax();
                          if (context.mounted) {
                            SystemNavigator.pop();
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Insufficient Funds. Please top up.',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Walk Away button (outlined / secondary) ──
                  SizedBox(
                    width: double.infinity,
                    child: PremiumPrimaryButton(
                      label: 'Walk Away',
                      icon: CupertinoIcons.xmark,
                      borderColor: Colors.white.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                      onPressed: () => NativeBridge.goHome(),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Wallet balance pill ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Consumer<AppState>(
                      builder: (context, state, _) {
                        return Text(
                          'Wallet Balance: \$${state.walletBalance.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context2, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Top Right Wallet Icon ──
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(CupertinoIcons.creditcard, size: 28),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const WalletScreen()),
                    );
                  },
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
              if (!_hasPermission) _PermissionBanner(isDark: isDark),

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

              const Spacer(),

              // ── Preview button ──
              Center(
                child: PremiumPrimaryButton(
                  label: 'Preview App Block',
                  icon: CupertinoIcons.eye_fill,
                  onPressed: () => _showBlockOverlay(context),
                ),
              ),

              const SizedBox(height: 64),
            ],
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
  const _PermissionBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A1C1C) : const Color(0xFFFFF0EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.redAccent.withValues(alpha: 0.3)
              : Colors.redAccent.withValues(alpha: 0.15),
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
            onTap: () => NativeBridge.openAccessibilitySettings(),
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
