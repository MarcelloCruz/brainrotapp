package com.example.brainrot_app

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppMonitorService : AccessibilityService() {

    companion object {
        private const val TAG = "DopamineTax"
        private const val DAILY_LIMIT_MINS = 60

        /** MVP: TikTok-only package targets. */
        private val BLOCKED_PACKAGES = setOf(
            "com.zhiliaoapp.musically",   // TikTok (global)
            "com.ss.android.ugc.trill",   // TikTok (regional variant)
        )
    }

    // ── Foreground time tracking ─────────────────────────────────────────────
    /** Timestamp (ms) when TikTok last entered the foreground. */
    private var tiktokStartTime: Long = 0L

    /** Whether TikTok is currently the foreground app. */
    private var isTikTokForeground: Boolean = false

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "AppMonitorService connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return

        // Exclude our own app from processing
        if (packageName == "com.example.brainrot_app") return

        Log.d(TAG, "App opened: $packageName")

        val isTikTok = packageName in BLOCKED_PACKAGES

        // ── Track foreground time ────────────────────────────────────────────
        if (isTikTok && !isTikTokForeground) {
            // TikTok just entered foreground — start the clock.
            tiktokStartTime = System.currentTimeMillis()
            isTikTokForeground = true
            Log.d(TAG, "TikTok entered foreground. Timer started.")
        } else if (!isTikTok && isTikTokForeground) {
            // User left TikTok — accumulate elapsed time.
            accumulateTime()
        }

        // ── Conditional block check ──────────────────────────────────────────
        if (isTikTok) {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val isUnlocked = prefs.getBoolean("flutter.isUnlockedForToday", false)

            if (isUnlocked) {
                Log.d(TAG, "User has paid — allowing $packageName")
                return
            }

            // Flush any in-progress session time before checking the limit.
            if (isTikTokForeground && tiktokStartTime > 0) {
                accumulateTime()
                // Restart the timer since user is still in TikTok.
                tiktokStartTime = System.currentTimeMillis()
                isTikTokForeground = true
            }

            val accumulatedMins = prefs.getLong("flutter.timeUsedMins", 0L)

            if (accumulatedMins >= DAILY_LIMIT_MINS) {
                Log.d(TAG, "INTERCEPTING blocked app: $packageName (used ${accumulatedMins}m / ${DAILY_LIMIT_MINS}m)")
                val intent = Intent(this, MainActivity::class.java).apply {
                    action = "com.dopaminetax.BLOCK"
                    putExtra("block_trigger", true)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NO_ANIMATION
                }
                startActivity(intent)
            } else {
                Log.d(TAG, "Within daily allowance ($accumulatedMins m / $DAILY_LIMIT_MINS m) — allowing $packageName")
            }
        }
    }

    /**
     * Accumulate the elapsed foreground time since [tiktokStartTime]
     * into the SharedPreferences counter that Flutter also reads.
     */
    private fun accumulateTime() {
        if (tiktokStartTime <= 0) return

        val elapsed = System.currentTimeMillis() - tiktokStartTime
        val elapsedMins = (elapsed / 60_000).toInt()

        if (elapsedMins > 0) {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val current = prefs.getLong("flutter.timeUsedMins", 0L)
            val updated = current + elapsedMins
            prefs.edit().putLong("flutter.timeUsedMins", updated).apply()
            Log.d(TAG, "Accumulated ${elapsedMins}m. Total: ${updated}m / ${DAILY_LIMIT_MINS}m")

            // Push the live update to Flutter so the UI rebuilds.
            MainActivity.pushTimeUpdate(updated)
        }

        tiktokStartTime = 0L
        isTikTokForeground = false
    }

    override fun onInterrupt() {
        Log.d(TAG, "AppMonitorService interrupted")
    }
}

/*
 * =========================================================================
 * MVP: IG Reels Anti-Deflector logic disabled.
 * Preserved here per project rules (no destructive overwrites).
 * =========================================================================
 *
 * Previously, when packageName == "com.instagram.android", the service
 * performed recursive UI node scanning via findAndDeflectReels():
 * - Detected when the "Reels" tab was selected (isSelected == true)
 * - Clicked the "Home" tab to exit immersive video player
 * - Deep-linked user to Instagram DMs via ig://direct_v2
 *   (with instagram://direct-inbox fallback)
 *
 * To re-enable: move this block back into onAccessibilityEvent(),
 * add "com.instagram.android" back to BLOCKED_PACKAGES,
 * and restore typeWindowContentChanged in accessibility_service_config.xml.
 * =========================================================================
 */
