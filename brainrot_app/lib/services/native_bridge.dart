import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/app_state.dart';
import '../providers/auth_state.dart' as app_auth;

/// Thin wrapper around the native MethodChannel for Android/iOS communication.
class NativeBridge {
  static const platform = MethodChannel('com.dopaminetax/native');

  /// Returns `true` when the AppMonitorService is enabled in system settings.
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final bool result = await platform.invokeMethod(
        'checkAccessibilityPermission',
      );
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Launches the system Accessibility Settings so the user can enable the
  /// service manually.
  static Future<void> openAccessibilitySettings() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
    } on PlatformException {
      // Silently ignore on non-Android platforms.
    }
  }

  /// Returns `true` when the app has SYSTEM_ALERT_WINDOW (overlay) permission.
  static Future<bool> checkOverlayPermission() async {
    try {
      final bool result = await platform.invokeMethod('checkOverlayPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the system overlay permission settings for this app.
  static Future<void> openOverlaySettings() async {
    try {
      await platform.invokeMethod('openOverlaySettings');
    } on PlatformException {
      // Silently ignore on non-Android platforms.
    }
  }

  /// Sends the user to the Android home screen (launcher).
  static Future<void> goHome() async {
    try {
      await platform.invokeMethod('goHome');
    } on PlatformException {
      // Silently ignore on non-Android platforms.
    }
  }

  /// Reads the accumulated TikTok usage time (in minutes) directly from
  /// the native SharedPreferences, bypassing Flutter's in-memory cache.
  static Future<int> getUsageTime() async {
    try {
      final int result = await platform.invokeMethod('getUsageTime');
      return result;
    } on PlatformException {
      return 0;
    }
  }

  /// Writes a specific usage time back to the native layer (for God Mode testing).
  static Future<void> setUsageTime(int minutes) async {
    try {
      await platform.invokeMethod('setUsageTime', minutes);
    } on PlatformException {
      // Silently ignore on non-Android platforms.
    }
  }

  /// Prompts the user for iOS Screen Time access (Family Controls).
  static Future<bool> requestIOSScreenTimePermission() async {
    try {
      final bool result = await platform.invokeMethod(
        'requestScreenTimePermission',
      );
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Checks if the user has already granted Screen Time permission.
  static Future<bool> checkIOSScreenTimePermission() async {
    try {
      final bool result = await platform.invokeMethod('checkScreenTimePermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the native iOS SwiftUI picker to select apps to block.
  static Future<void> selectIOSAppsToBlock() async {
    try {
      await platform.invokeMethod('selectAppsToBlock');
    } on PlatformException {
      // Silently ignore on non-iOS platforms or if it fails.
    }
  }

  /// Enables or disables the iOS ManagedSettingsStore shield based on payment status.
  static Future<void> setIOSShieldStatus(bool enable) async {
    try {
      await platform.invokeMethod('setShieldStatus', {'enable': enable});
    } on PlatformException {
      // Silently ignore on non-iOS platforms or if it fails.
    }
  }

  /// Checks if the app was launched via a block intent.
  static Future<bool> checkBlockTrigger() async {
    try {
      final bool result = await platform.invokeMethod('checkBlockTrigger');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Clears the block trigger state.
  static Future<void> clearBlockTrigger() async {
    try {
      await platform.invokeMethod('clearBlockTrigger');
    } on PlatformException {
      // Ignore
    }
  }

  /// Initializes the method call handler for pushing updates from Native to Flutter.
  static void initialize(GlobalKey<NavigatorState> navigatorKey, AppState appState, app_auth.AuthState authState) {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'triggerBlockOverlay') {
        if (authState.isAuthenticated && !appState.isTaxPaid) {
          navigatorKey.currentState?.pushNamed('/block');
          clearBlockTrigger();
        }
      } else if (call.method == 'updateUsageTime') {
        final int minutes = call.arguments as int;
        appState.updateTimeUsed(minutes);
      }
    });
  }
}

