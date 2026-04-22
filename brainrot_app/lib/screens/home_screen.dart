import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/frosted_glass_overlay.dart';
import '../widgets/premium_primary_button.dart';

/// Minimalist home screen for Dopamine Tax.
///
/// Features a large typographic header and a button that previews the
/// frosted-glass "App Block" overlay.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    'TikTok is blocked.\nPay the tax or walk away.',
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
                      label: 'Pay \$0.50 to Unlock (15m)',
                      icon: CupertinoIcons.creditcard,
                      onPressed: () {
                        // TODO: Wire to wallet service
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Dismiss button (secondary) ──
                  SizedBox(
                    width: double.infinity,
                    child: PremiumPrimaryButton(
                      label: 'Walk Away',
                      icon: CupertinoIcons.xmark,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      foregroundColor: Colors.white70,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Wallet balance indicator ──
                  Text(
                    'Wallet Balance: \$10.00',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 72),

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

              // ── Subtitle ──
              Text(
                'Take control of your attention.\nMake doomscrolling cost you.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 17,
                  height: 1.55,
                ),
              ),

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
