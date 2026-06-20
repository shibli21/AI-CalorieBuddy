# CalorieBuddy

An AI-powered calorie & nutrition tracker for **iOS 26+**. Snap a photo of your
meal and let AI log the calories and macros — with water, intermittent fasting,
weight tracking, streaks, a friendly mascot, and a freemium Plus tier.

Built in SwiftUI + SwiftData, original brand, inspired by (not copied from) an
analyzed competitor. See [`docs/`](docs) for the full story.

## Status
Feature-complete MVP across all analyzed flows. Built on Windows (code only);
compile & run on macOS + Xcode 26 — see [`docs/SETUP.md`](docs/SETUP.md).

## Docs
- [`docs/SPEC.md`](docs/SPEC.md) — product & technical spec, locked decisions
- [`docs/PLAN.md`](docs/PLAN.md) — phased build plan
- [`docs/SETUP.md`](docs/SETUP.md) — build it on a Mac (capabilities, proxy, StoreKit)
- [`docs/BRAND.md`](docs/BRAND.md) — palette, type, mascot (Pip the fox)
- [`docs/ios26-notes.md`](docs/ios26-notes.md) — iOS 26/27 research (Liquid Glass, AI, HealthKit, StoreKit)
- [`docs/competitor-screens.md`](docs/competitor-screens.md) — the 158-screen reference catalog

## Architecture
- **SwiftUI + Observation** (`@Observable` services in `@Environment`), value-based `NavigationStack`.
- **SwiftData** canonical store with optional **CloudKit** sync; CloudKit-safe models.
- **AI scan:** photo → serverless proxy → Claude vision → structured nutrition JSON. See [`proxy/`](proxy).
- **Services:** AI, HealthKit (opt-in mirror), StoreKit 2 (Pro), local notifications.

```
CalorieBuddy/
├─ App/            app entry, routing, tab shell
├─ Core/           model container, nutrition math, AI client, services
├─ Models/         SwiftData models + enums
├─ DesignSystem/   theme, type, layout, components (rings, cards, mascot…)
└─ Features/       Onboarding, Dashboard, Scan, FoodDetail, Diary, Water,
                   Fasting, Stats, Settings, Paywall
proxy/             Cloudflare Worker that holds the Anthropic key
```

## Quick start
1. Open `CalorieBuddy.xcodeproj` in Xcode 26 on a Mac.
2. Enable HealthKit / iCloud (CloudKit) / Sign in with Apple capabilities.
3. (Optional) Deploy [`proxy/`](proxy) and set `CB_AI_PROXY_URL`; otherwise the
   scanner runs in demo mode with a mock result.
4. Select the `Configuration.storekit` config in the scheme to test purchases.
5. Run on an iOS 26 simulator or device (Liquid Glass renders best on device).

🤖 Built with Claude Code.
