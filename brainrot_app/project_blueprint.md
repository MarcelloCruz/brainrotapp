# Project: Dopamine Tax
**Core Concept:** A digital wellbeing Flutter app designed to combat short-video doomscrolling (TikTok, IG Reels, YT Shorts) using behavioral economics and loss aversion.

## The Mechanics
* **Total App Block (e.g., TikTok):** When the user opens the app, a full-screen overlay appears. Options: Pay a micro-transaction to use it, or hit "OK" to be kicked back to the home screen.
* **Surgical Block (e.g., Instagram Reels / YT Shorts):** Only the specific short-video tabs are blocked. If clicked, the app redirects the user to the platform's home feed and prompts for payment. Other features (DMs, long-form videos) remain free.

## Tech Stack
* **Framework:** Flutter (Dart)
* **Android Native Layer:** Kotlin (Requires Accessibility API for Surgical Blocks and overlay permissions).
* **iOS Native Layer:** Swift (Requires Screen Time API / Family Controls for blocking).
* **Monetization Strategy:** In-app wallet/top-up system to avoid per-transaction app store fees.

## Target Audience
Gen Z / Millennials aware of screen-time addiction, and parents managing Gen Alpha screen time.
