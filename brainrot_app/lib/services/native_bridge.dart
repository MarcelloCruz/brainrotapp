import 'package:flutter/services.dart';

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

  /// Sends the user to the Android home screen (launcher).
  static Future<void> goHome() async {
    try {
      await platform.invokeMethod('goHome');
    } on PlatformException {
      // Silently ignore on non-Android platforms.
    }
  }
}
