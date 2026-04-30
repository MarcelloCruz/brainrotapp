import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/native_bridge.dart';
import 'premium_primary_button.dart';

/// A full-screen frosted-glass overlay for the "Total App Block" feature.
///
/// Uses [BackdropFilter] with a Gaussian blur to create a premium iOS-style
/// frosted glass effect over whatever content is behind it.
///
/// The "Pay" button performs an **instant wallet deduction** — no Stripe
/// checkout. If the balance is insufficient, a SnackBar prompts the user
/// to top up via the Profile sheet.
class FrostedGlassOverlay extends StatefulWidget {
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
  State<FrostedGlassOverlay> createState() => _FrostedGlassOverlayState();
}

class _FrostedGlassOverlayState extends State<FrostedGlassOverlay> {
  bool _isProcessing = false;

  /// Instant wallet deduction flow:
  /// 1. Check if wallet balance >= tax amount.
  /// 2. If yes, deduct from Supabase, flip isTaxPaid, dismiss overlay.
  /// 3. If no, show an "Insufficient funds" SnackBar.
  Future<void> _handleInstantPay() async {
    if (_isProcessing) return;

    final state = context.read<AppState>();

    if (state.walletBalance < state.taxAmount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient funds. Please top up in your profile.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await state.payTax();

      if (!mounted) return;

      if (success) {
        if (widget.onDismiss != null) {
          widget.onDismiss!();
        } else {
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process payment. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('FrostedGlassOverlay: Payment error — $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: SizedBox.expand(
          child: Stack(
            children: [
              // ── Frosted glass backdrop ──
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blurSigma,
                    sigmaY: widget.blurSigma,
                  ),
                  child: Container(color: widget.tintColor),
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

                            // ── Pay button (instant wallet deduction) ──
                            SizedBox(
                              width: double.infinity,
                              child: _isProcessing
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : PremiumPrimaryButton(
                                      label:
                                          'Pay ${context.read<AppState>().formatPrice(context.read<AppState>().taxAmount)} (Unlocks till midnight)',
                                      icon: CupertinoIcons.creditcard,
                                      onPressed: _handleInstantPay,
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
                                onPressed: _isProcessing
                                    ? null
                                    : () {
                                        if (widget.onDismiss != null) {
                                          widget.onDismiss!();
                                        } else {
                                          Navigator.of(context).pop();
                                        }
                                        NativeBridge.goHome();
                                      },
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
