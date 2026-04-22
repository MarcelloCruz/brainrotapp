package com.example.brainrot_app

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppMonitorService : AccessibilityService() {

    companion object {
        private const val TAG = "DopamineTax"

        /** Package names we intercept. */
        private val BLOCKED_PACKAGES = setOf(
            "com.zhiliaoapp.musically",   // TikTok
            "com.instagram.android",       // Instagram
        )
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "AppMonitorService connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            Log.d(TAG, "App opened: $packageName")

            if (packageName in BLOCKED_PACKAGES) {
                // Check if the user has already paid today
                val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val isUnlocked = prefs.getBoolean("flutter.isUnlockedForToday", false)

                if (isUnlocked) {
                    Log.d(TAG, "User has paid — allowing $packageName")
                    return
                }

                Log.d(TAG, "INTERCEPTING blocked app: $packageName")
                val intent = Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                startActivity(intent)
            }
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "AppMonitorService interrupted")
    }
}
