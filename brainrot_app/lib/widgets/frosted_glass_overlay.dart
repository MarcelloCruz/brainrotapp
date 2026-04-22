import 'dart:ui';
import 'package:flutter/material.dart';

/// A full-screen frosted-glass overlay for the "Total App Block" feature.
///
/// Uses [BackdropFilter] with a Gaussian blur to create a premium iOS-style
/// frosted glass effect over whatever content is behind it.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierColor: Colors.transparent,
///   builder: (_) => FrostedGlassOverlay(
///     onDismiss: () => Navigator.pop(context),
///     child: YourOverlayContent(),
///   ),
/// );
/// ```
class FrostedGlassOverlay extends StatelessWidget {
  /// Content displayed on top of the frosted glass.
  final Widget child;

  /// Called when the overlay should be dismissed.
  final VoidCallback? onDismiss;

  /// Blur intensity. Default `30` matches iOS-level frosted glass.
  final double blurSigma;

  /// Tint applied over the blur.
  final Color tintColor;

  const FrostedGlassOverlay({
    super.key,
    required this.child,
    this.onDismiss,
    this.blurSigma = 30.0,
    this.tintColor = const Color(0x80000000),
  });

  @override
  Widget build(BuildContext context) {
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
                    child: child,
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
