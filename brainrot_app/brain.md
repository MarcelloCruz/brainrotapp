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

### Developer Debug Reset (Completed)
- Added `resetDebugState()` to `AppState` — clears `isUnlockedForToday`, resets `timeUsedMins = 60`, and persists `false` to SharedPreferences.
- Created `lib/screens/settings_screen.dart` with Tax Amount display and a red "Developer: Reset App State" button.
- Added gear icon (`CupertinoIcons.gear_solid`) to home screen top-right bar, navigating to `SettingsScreen` via `CupertinoPageRoute`.
- `flutter analyze` — zero issues.

### Transparent Overlay Fix (Completed)
- **Root cause**: The Flutter app was painting a solid opaque background instead of being transparent when launched as an overlay over TikTok.
- **Android themes**: Both `LaunchTheme` and `NormalTheme` in `values/styles.xml` and `values-night/styles.xml` were forced to transparent (`android:windowIsTranslucent=true`, `android:windowBackground=@android:color/transparent`, `android:colorBackgroundCacheHint=@null`).
- **MaterialApp**: Added `color: Colors.transparent` to the root `MaterialApp` in `lib/main.dart`.
- **OverlayScreen**: Changed `Scaffold(backgroundColor: Colors.black87)` → `Scaffold(backgroundColor: Colors.transparent)` and wrapped the body in `FrostedGlassOverlay` for a proper blur effect over the underlying app.
- **Key lesson**: Every layer in the stack (Android Activity theme → Flutter MaterialApp → Scaffold) must explicitly be transparent; any single opaque layer kills the overlay effect.
- `flutter analyze` — zero issues.

### Screen Isolation & Opaque Home Screen (Completed)
- Isolated the app blocked UI into `FrostedGlassOverlay` widget.
- Stripped `OverlayScreen` of any duplicated Home Screen elements, retaining strictly the `FrostedGlassOverlay`.
- Set `HomeScreen` `Scaffold` `backgroundColor` to `theme.scaffoldBackgroundColor` making it explicitly opaque so the app behaves like a normal app when launched from the app drawer.

### Dynamic Localized Pricing & Smart Rounding (Completed)
- Created `lib/services/pricing_service.dart` — base price €0.50 with mock exchange rates (USD, GBP, RON, AUD, JPY) and smart rounding (nearest 0.50 for standard currencies, nearest 50 for large-value currencies like JPY).
- `AppState` now auto-detects device locale via `Platform.localeName`, derives currency code, symbol (via `intl` package), and local tax amount on construction.
- Stripped **all hardcoded `$` and `2.00`** from `frosted_glass_overlay.dart`, `wallet_screen.dart`, `dashboard_card.dart`, and `settings_screen.dart` — replaced with `state.formatPrice()` and `state.taxAmount`.
- Wallet top-up pills now scale dynamically (10×, 20×, 40× tax amount).
- Mock transactions in `AppState` use localized amounts. Initial wallet balance set to 20× tax for usability.
- `flutter analyze` — zero errors.

### Home Screen Production Overhaul (Completed)
- Nuked demo artifacts (`Preview App Block` button).
- Redesigned `DashboardCard` to include a visually intuitive `LinearProgressIndicator` below the "Daily Allowance Used" text. Colors adapt based on progress (<50% green, 50-99% yellow, 100% red).
- Added a new "Target Apps" section below the dashboard with a premium list of monitored apps (TikTok, Instagram, YouTube) and individual `CupertinoSwitch` toggles.
- Wired switches to a new `trackedApps` map inside `AppState`.
- Refined the permission banner: it now displays a subtle, green "Shield Active" pill when the accessibility permission is granted, and the red "Action Required" banner when missing.

### Premium Dark Glassmorphism Aesthetic (Completed)
- Overhauled UI design language to match the landing page.
- Forced `ThemeMode.dark` as the primary identity in `lib/main.dart`.
- Updated `AppTheme` palette: Deep Midnight Blue background (`#0D0D16`), Vibrant Neon Blue accent (`#1D4ED8`), and Neon Green (`#39FF14`) for success indicators.
- Updated headers to use a heavy `FontWeight.w800` to match landing page typography.
- Replaced `HomeScreen` solid background with a subtle linear gradient giving depth.
- Converted `DashboardCard` and `TargetAppsList` to premium glassmorphic cards (translucent dark background with a subtle white border and high border radius).
- Re-styled the `LinearProgressIndicator` to use a rounded thick bar with a neon green glow.
- Modernized `PermissionBanner` with a sleek dark card and thin glowing red border.

### iOS Native Layer — Phase 1 (Completed)
- Begun integration of Apple's FamilyControls framework.
- Updated `AppDelegate.swift` to handle `requestScreenTimePermission` via MethodChannel `com.dopaminetax/native`.
- Implemented `AuthorizationCenter.shared.requestAuthorization(for: .individual)` to prompt the user for Screen Time access.
- Added `requestIOSScreenTimePermission()` to `NativeBridge`.
- **Note**: Developer must manually add the "Family Controls" entitlement in Xcode ("Signing & Capabilities").

### iOS Native Layer — Phase 2 (Completed)
- Implemented `ScreenTimeManager.swift` to handle `ManagedSettingsStore` and persist selection state.
- Created `FamilyPickerView.swift` to wrap SwiftUI `FamilyActivityPicker`.
- Wired platform-aware button in `HomeScreen` to invoke native Picker.
- *(Note: Actually running the Picker on device currently blocked by Apple provisioning profile restrictions).*

### Android Native Layer — Anti-Reels Deflector (Completed)
- Added `typeWindowContentChanged` to `accessibility_service_config.xml`.
- Updated `AppMonitorService.kt` with recursive UI node scanning (`findAndDeflectReels`).
- Identifies when the "Reels" tab is selected (`isSelected == true`).
- Deflects user by simulating a click on the "Home" tab to exit immersive mode.
- Deep-links the user straight to Instagram Direct Messages via `ig://direct_v2` (or `instagram://direct-inbox` fallback).

### Next Steps
- Add YouTube Shorts (`com.google.android.youtube`) to the blocked packages list.
- Implement usage-time tracking inside `AppMonitorService` (start/stop timer per monitored package).

### TikTok MVP Loop (Completed)
- **Pivot**: Dropped iOS, YouTube, and Instagram for a focused TikTok-only MVP.
- **Android — AppMonitorService.kt**:
  - Targeted only TikTok packages: `com.zhiliaoapp.musically` (global) and `com.ss.android.ugc.trill` (regional).
  - Removed `com.instagram.android` from `BLOCKED_PACKAGES`.
  - Commented out the entire IG Reels Anti-Deflector logic (preserved as documentation block per project rules).
  - Implemented real foreground time tracking: records timestamp when TikTok enters foreground, accumulates elapsed minutes to `SharedPreferences` key `flutter.timeUsedMins` when user leaves.
  - Conditional blocking: only fires the block intent when accumulated time ≥ 60 minutes AND user has not paid for the day.
- **Android — accessibility_service_config.xml**:
  - Removed `typeWindowContentChanged` (was only for IG Reels node scanning).
  - Set `canRetrieveWindowContent="false"` since UI tree scanning is disabled.
- **Flutter — app_state.dart**:
  - `_trackedApps` reduced to `{'TikTok': true}`.
  - Added `loadPersistedState()` — hydrates `isUnlockedForToday` and `timeUsedMins` from SharedPreferences on startup.
  - Added `syncTimeFromNative()` — re-reads `timeUsedMins` from SharedPreferences when app resumes.
  - Added `updateTimeUsed(int)` — accepts pushed time updates from MethodChannel.
  - `resetDebugState()` now resets `timeUsedMins = 0` (was 60) and persists both flags.
  - Removed Instagram mock transaction.
- **Flutter — main.dart**:
  - Made `main()` async; calls `appState.loadPersistedState()` before `runApp`.
  - Added MethodChannel handler for `updateUsageTime` to receive live time pushes from Kotlin.
  - Switched from `ChangeNotifierProvider(create:)` to `ChangeNotifierProvider.value(value:)`.
- **Flutter — home_screen.dart**:
  - `didChangeAppLifecycleState(resumed)` now calls `syncTimeFromNative()` to refresh dashboard.
- **Bonus fixes** (resolved pre-existing warnings):
  - `dashboard_card.dart`: Removed unused `app_theme.dart` import. Progress bar now uses the dynamic `color` variable (green/yellow/red) instead of hardcoded neon green.
  - `app_theme.dart`: Added `// ignore: unused_field` for `_neonGreen` design system palette constant.
- `flutter analyze` — **zero issues**.

### Next Steps (Post-MVP)
- Re-enable Instagram Reels deflection and add YouTube Shorts when ready to expand.
- Add a persistent foreground notification to keep the AccessibilityService alive against battery optimization.
- Implement midnight auto-reset for `isUnlockedForToday` and `timeUsedMins`.
- Pursue TestFlight-ready iOS builds once provisioning is resolved.

