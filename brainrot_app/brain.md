# Dopamine Tax - Brain

## Project Understanding
- App: **Dopamine Tax**
- Goal: Combats doomscrolling via app blocks and micro-transactions using behavioral economics.
- Mechanics:
  - **Daily Allowance**: 1h free daily across short-form video apps; block triggers when limit is hit.
  - **Dopamine Tax**: One-time $2.00 daily penalty to unlock after limit is reached.
  - Surgical blocking (e.g., IG Reels) — only short-video tabs count toward allowance.
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
- Overlay includes "Pay $2.00 to Unlock for Today" primary button, outlined "Walk Away" button, and "Wallet Balance: $10.00" pill indicator.
- Layout: Lock Icon → Title → Subtitle → Pay → Walk Away → Balance pill.
- `flutter analyze` — zero issues.

### UI Polish & Home Dashboard (Completed)
- Updated `PremiumPrimaryButton` with `borderColor` parameter for outlined/ghost variant.
- "Walk Away" button now renders as outlined (translucent white border, transparent fill, crisp white text).
- Wallet Balance wrapped in a translucent pill capsule with pure white text for visual weight.
- Created `lib/widgets/dashboard_card.dart` — Premium soft-cornered card with "Daily Allowance Used: 60m / 60m" and "Tax Paid: $2.50" stats side-by-side, Cupertino shadow in light mode.
- Placed `DashboardCard` on home screen below the subtitle.
- `flutter analyze` — zero issues.

### Daily Allowance Model Pivot (Completed)
- Updated `project_blueprint.md` mechanics: 1h free daily allowance → block trigger → $2.00 one-time daily penalty.
- Overlay subtitle: "Daily limit (1h) reached."; pay button: "Pay $2.00 to Unlock for Today".
- Dashboard stat: "Daily Allowance Used: 60m / 60m".
- `flutter analyze` — zero issues.

### Wallet Screen UI (Completed)
- Designed `lib/screens/wallet_screen.dart` with a large "$10.00" balance typography matching Apple Wallet aesthetics.
- Added top-up section with 3 pill-shaped buttons ($5, $10, $20) and a `PremiumPrimaryButton`.
- Added simulated "Recent Activity" list showing Deductions (`CupterinoColors.destructiveRed`) and Deposits (`CupertinoColors.activeGreen`).
- Hooked up `home_screen.dart` to navigate to the new `WalletScreen` via a `CupertinoIcons.creditcard` icon button in the top right.
- Connected via smooth `CupertinoPageRoute` transition.

### Text Overflow & Reset Documentation (Completed)
- Fixed a 21px overflow error on the payment button by shortening the text to "Pay $2.00 (Unlocks till midnight)".
- Wrapped the `PremiumPrimaryButton` label in a `Flexible > FittedBox` (`BoxFit.scaleDown`) to dynamically shrink text if it's too long, preventing layout errors.
- Documented the "Midnight Reset" rules in `project_blueprint.md` — daily unlimited access until midnight upon payment, with a fresh 1-hour allowance granted at reset.

### State Management & Reactive UI (Completed)
- Integrated `provider` package.
- Created `AppState` (`ChangeNotifier`) acting as the global source of truth for `walletBalance`, `timeUsedMins`, `isUnlockedForToday`, and `recentActivity`.
- Updated `project_blueprint.md` with the "Universal Unlock" rule (paying once unlocks all apps until midnight).
- Wired `home_screen.dart`, `wallet_screen.dart`, and `dashboard_card.dart` to read and update state (`context.watch`/`context.read`).
- Implemented `addFunds()` via top-up pills and `payTax()` check with dynamic "Insufficient Funds" SnackBar.

### Android Native Layer — Phase 1 (Completed)
- Added `SYSTEM_ALERT_WINDOW` permission and declared `AppMonitorService` in `AndroidManifest.xml` with `BIND_ACCESSIBILITY_SERVICE`.
- Created `accessibility_service_config.xml` — monitors `typeWindowStateChanged`, `feedbackGeneric`, `canRetrieveWindowContent`.
- Created `AppMonitorService.kt` extending `AccessibilityService` — logs `"App opened: <packageName>"` on window state changes.
- Rewrote `MainActivity.kt` with MethodChannel `com.dopaminetax/native`:
  - `checkAccessibilityPermission` → returns `Boolean` by scanning `ENABLED_ACCESSIBILITY_SERVICES`.
  - `openAccessibilitySettings` → launches system accessibility settings intent.
- Created `res/values/strings.xml` with `accessibility_service_description`.
- `flutter analyze` — zero issues.

### Android Native Layer — Phase 2 (Completed)
- Created `lib/services/native_bridge.dart` — static wrapper around MethodChannel `com.dopaminetax/native` with `checkAccessibilityPermission()` and `openAccessibilitySettings()`.
- Converted `HomeScreen` from `StatelessWidget` → `StatefulWidget` with `WidgetsBindingObserver` to re-check permission on app resume.
- Added premium red/orange permission banner below the header when accessibility is disabled, with an "Enable" pill button that opens system settings.
- Updated `AppMonitorService.kt` with intercept logic: when TikTok (`com.zhiliaoapp.musically`) or Instagram (`com.instagram.android`) is detected, it fires an `Intent` to `MainActivity` with `FLAG_ACTIVITY_NEW_TASK | FLAG_ACTIVITY_CLEAR_TOP`, yanking the user back to Dopamine Tax.
- `flutter analyze` — zero issues.

### Android Native Layer — Phase 3: Transparent Overlay & State Sync (Completed)
- Made `NormalTheme` in `styles.xml` translucent (`windowIsTranslucent`, transparent background) so the Flutter app renders as a see-through overlay.
- Added `goHome` method to `MainActivity.kt` and `NativeBridge` — launches `ACTION_MAIN` + `CATEGORY_HOME` intent.
- `AppState.payTax()` now async: persists `isUnlockedForToday = true` to `SharedPreferences` so the Kotlin service can read it.
- `AppMonitorService.kt` reads `FlutterSharedPreferences` before intercepting — skips the block if the user has already paid.
- Pay button calls `SystemNavigator.pop()` after payment (hides Flutter, leaves user in the app they paid for).
- Walk Away button calls `NativeBridge.goHome()` (sends user to the Android home screen).
- `flutter analyze` — zero issues.

### Next Steps
- Add YouTube Shorts (`com.google.android.youtube`) to the blocked packages list.
- Implement usage-time tracking inside `AppMonitorService` (start/stop timer per monitored package).
- Implement iOS native layer (Screen Time API / Family Controls).
