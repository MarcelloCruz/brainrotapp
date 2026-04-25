import 'package:flutter/material.dart';
import '../widgets/frosted_glass_overlay.dart';

/// Standalone transparent overlay screen shown when a blocked app is intercepted.
///
/// Launched via the `/block` route when the Kotlin AccessibilityService
/// fires an intent with action `com.dopaminetax.BLOCK`.
class OverlayScreen extends StatelessWidget {
  const OverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: FrostedGlassOverlay(),
    );
  }
}
