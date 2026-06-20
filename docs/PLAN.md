# CalorieBuddy — Build Plan

Phased so each layer compiles on top of a stable foundation. Phases 0–2 are the backbone; 3+ are features that reuse it. Tracked in the session task list (#1–#19).

## Phase 0 — Docs & project config  *(tasks #1, #2)*
- `SPEC.md`, `PLAN.md`, `SETUP.md`, `competitor-screens.md`, `ios26-notes.md`.
- pbxproj build-setting edits: Info.plist permission keys + `CODE_SIGN_ENTITLEMENTS`.
- `CalorieBuddy.entitlements` (HealthKit, iCloud/CloudKit, Sign in with Apple).
- Remove template `Item.swift` / template `ContentView.swift`.

## Phase 1 — Foundation  *(tasks #3, #4)*
- **DesignSystem**: `Theme`, `Typography`, `Spacing`, `Radius`, gradients, haptics.
- **Components**: `CBButton`, `CBCard`, `GlassPanel`, `CalorieRing`, `MacroBars`, `Chip`, `PageDots`, `StatTile`, `SegmentedPicker`, `Stepper/Wheel`, `ToastView`.
- **Models** (SwiftData) + **Enums** + **NutritionMath** (+ unit tests where pure).

## Phase 2 — Services & app shell  *(tasks #5, #6)*
- `AIService` (proxy client + JSON schema), `HealthKitService`, `StoreService`, `NotificationService`, `AppState/Router`.
- `CalorieBuddyApp` (model container + environment), `RootView` gate, `MainTabView` (Liquid Glass tab bar + center scan).

## Phase 3 — Onboarding  *(task #7)* — competitor screens free_001–008, pro_001–055, 096, 131–141
Splash → ATT prime → welcome → 5-slide carousel → quiz (source, goal, additional goals, experience, "how it works", pet reveal + naming, reminders + notif perm, eating habits: meals/window/location/diet/restrictions, water, disclaimer, habit goals, confirmation, sex, age, activity, height, weight+BMI, summary, target weight, pace slider, realistic interstitial) → plan-calc loaders → plan reveal (projected progress, nutrition/fasting/hydration, social proof) → rating prompt → Sign in with Apple → paywall.

## Phase 4 — Today / Dashboard  *(task #8)* — 056, 057, 084–087, 095, 107–124
Calorie hero ring, macro bars, water/fasting/nutrition-score/fiber cards, streak, date calendar, meal list, coachmark, toasts, mascot reactions.

## Phase 5 — Camera + AI Scan  *(task #9)* — 058–069, 088–093
Camera tips/permission, capture (meal + label), scanning loader, AI ingredient review/edit, add/edit ingredient, meal date/time, confirm entry.

## Phase 6 — Food Detail + awards  *(task #10)* — 070–083, 094, 113–115
Meal detail (kcal/macros), ingredients, nutrition score, awards + multi-page education, info sheets, edit/delete, share.

## Phase 7 — Diary / Food Log  *(task #11)* — 091, 092, 112
Daily diary, meal log sheet, category picker, confirm food entry, manual add/search, favorites/recents.

## Phase 8 — Water  *(task #12)* — 117–122
Water states, entry sheet, goal setting, goal-reached celebration.

## Phase 9 — Fasting  *(task #13)* — 006–008(fasting), 019, 103–109, 141
Choose goal, start time, include-last-meal, active states, end/cancel warnings, timer/progress ring, streaks.

## Phase 10 — Stats / History  *(task #14)* — 086, 097–099, 125, 126
Swift Charts (weight, calories), streak celebrations, locked empty states, stats-ready success.

## Phase 11 — Settings + customization  *(task #15)* — 100–102, 127–150
Settings main, edit plan (calories/macros), personal details, eating prefs, units, calories display, app icon + background picker, mascot naming, privacy webview, delete account, logout.

## Phase 12 — Paywall + StoreKit  *(task #16)* — 046–051
Plus paywall (collapsed/expanded plans, comparison table, testimonials), `SubscriptionStoreView`, purchase success, freemium gating throughout, `.storekit` test config.

## Phase 13 — Brand & proxy & polish  *(tasks #17, #18, #19)*
Original mascot + brand kit + app icon; serverless Claude proxy + deploy doc; accessibility (Dynamic Type, VoiceOver, reduce-motion), `GlassEffectContainer` polish, dark mode, empty/loading/error states.

## Conventions
- One screen ≈ one file under `Features/<Area>/`. Shared bits go to `DesignSystem/`.
- Previews on every view (`#Preview`) with sample data via an in-memory container.
- No force-unwraps in app code; handle AI/permission/network failure paths.
- Strings centralized enough to localize later (String Catalog enabled).
