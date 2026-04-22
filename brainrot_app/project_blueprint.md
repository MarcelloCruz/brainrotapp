# Project: Dopamine Tax
**Core Concept:** A digital wellbeing Flutter app designed to combat short-video doomscrolling (TikTok, IG Reels, YT Shorts) using behavioral economics and loss aversion.

## The Mechanics
* **Daily Allowance:** Users receive a free daily allowance of 1 hour total across all monitored short-form video apps (TikTok, IG Reels, YT Shorts). Usage is tracked in the background.
* **Block Trigger:** Once the 1-hour daily limit is reached, a full-screen frosted-glass overlay blocks further access.
* **Dopamine Tax (Daily Penalty):** To regain access for the rest of the day, the user must pay a one-time daily "Dopamine Tax" ($2.00). If the user pays the daily Dopamine Tax, they gain unlimited access to the short-form content until midnight. At exactly midnight, the system resets, granting them a fresh 1-hour free allowance. Walking away means the apps stay blocked until midnight.
* **Universal Unlock:** Paying the daily Dopamine Tax does not just unlock one app. It acts as a master key. Paying the $2.00 fee instantly unlocks ALL restricted short-form platforms (TikTok, Reels, Shorts) simultaneously until the midnight reset.
* **Surgical Block (e.g., Instagram Reels / YT Shorts):** Only the specific short-video tabs count toward the allowance. Other features (DMs, long-form videos) remain free and untracked.

## Tech Stack
* **Framework:** Flutter (Dart)
* **Android Native Layer:** Kotlin (Requires Accessibility API for Surgical Blocks and overlay permissions).
* **iOS Native Layer:** Swift (Requires Screen Time API / Family Controls for blocking).
* **Monetization Strategy:** In-app wallet/top-up system to avoid per-transaction app store fees.

## Target Audience
Gen Z / Millennials aware of screen-time addiction, and parents managing Gen Alpha screen time.
