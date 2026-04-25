import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/native_bridge.dart';
import 'premium_primary_button.dart';

/// A full-screen frosted-glass overlay for the "Total App Block" feature.
///
/// Uses [BackdropFilter] with a Gaussian blur to create a premium iOS-style
/// frosted glass effect over whatever content is behind it.
class FrostedGlassOverlay extends StatelessWidget {
  /// Called when the overlay should be dismissed.
  final VoidCallback? onDismiss;

  /// Blur intensity. Default `30` matches iOS-level frosted glass.
  final double blurSigma;

  /// Tint applied over the blur.
  final Color tintColor;

  const FrostedGlassOverlay({
    super.key,
    this.onDismiss,
    this.blurSigma = 30.0,
    this.tintColor = const Color(0x80000000),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: onDismiss,
        child: SizedBox.expand(
          child: Stack(
            children: [
              // ── Frosted glass backdrop ──
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                  ),
                  child: Container(color: tintColor),
                ),
              ),

              // ── Overlay content ──
              Positioned.fill(
                child: SafeArea(
                  child: GestureDetector(
                    // Prevent taps on the content from dismissing the overlay.
                    onTap: () {},
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
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
                                label: 'Pay ${context.read<AppState>().formatPrice(context.read<AppState>().taxAmount)} (Unlocks till midnight)',
                                icon: CupertinoIcons.creditcard,
                                onPressed: () async {
                                  final state = context.read<AppState>();
                                  if (state.walletBalance >= state.taxAmount) {
                                    await state.payTax();
                                    if (context.mounted) {
                                      if (onDismiss != null) {
                                        onDismiss!();
                                      } else {
                                        SystemNavigator.pop();
                                      }
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                borderColor: Colors.white.withValues(
                                  alpha: 0.35,
                                ),
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
                                    'Wallet Balance: ${state.formatPrice(state.walletBalance)}',
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
