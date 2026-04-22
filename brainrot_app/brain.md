# Dopamine Tax - Brain

## Project Understanding
- App: **Dopamine Tax**
- Goal: Combats doomscrolling via app blocks and micro-transactions using behavioral economics.
- Mechanics:
  - Total app blocking via overlays.
  - Surgical app blocking (e.g., IG Reels) requiring Android Accessibility API / iOS Screen Time API.
  - In-app wallet to bypass store fees.

## Progress
- Analyzed `project_blueprint.md` and initialized task trackers.
- Scaffolded modern Flutter project architecture with `useMaterial3`.
- Implemented initial `DashboardScreen`, `OverlayScreen`, and `WalletScreen`.

### Apple-Inspired Design System (Completed)
- Rewrote `lib/theme/app_theme.dart` — Light & Dark themes with true black/white backgrounds, iOS vibrant blue (`#007AFF`) accent, zero Material shadows, Cupertino-style soft `BoxShadow` helpers, and platform-native typography.
- Created `lib/widgets/frosted_glass_overlay.dart` — Full-screen `BackdropFilter` blur overlay for the Total App Block feature.
- Created `lib/widgets/premium_primary_button.dart` — Stadium button with `AnimationController` scale-down animation and `HapticFeedback.mediumImpact`.
- Created `lib/screens/home_screen.dart` — Minimalist home screen with large "Dopamine Tax" header and overlay preview button.
- Updated `lib/main.dart` to route to `HomeScreen`, disabled debug banner.
- `flutter analyze` passes with **zero issues**.
### Mock Payment UI in Overlay (Completed)
- Updated `home_screen.dart` overlay with "Pay $0.50 to Unlock (15m)" primary button, "Walk Away" secondary button, and "Wallet Balance: $10.00" indicator.
- Layout follows Apple-like vertical column: Lock Icon → Title → Subtitle → Pay → Dismiss → Balance.
- `flutter analyze` — zero issues.

### Next Steps
- Wire the existing `DashboardScreen`, `OverlayScreen`, and `WalletScreen` into the new design system.
- Implement MethodChannels and write native Kotlin/Swift implementations for system-level app blocking.
