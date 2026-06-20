# CalorieBuddy — Product & Technical Spec

> An AI-powered calorie & nutrition tracker for iOS 26+. Snap a photo, let AI log it.
> Original brand, inspired by — not copying — the analyzed competitor "BitePal".
> Companion docs: [`competitor-screens.md`](competitor-screens.md) (full screen catalog) · [`ios26-notes.md`](ios26-notes.md) (research) · [`PLAN.md`](PLAN.md) (build phases) · [`SETUP.md`](SETUP.md) (build it).

## 1. Locked decisions
| Area | Decision |
|---|---|
| **AI engine** | Cloud **Claude vision** → structured nutrition JSON, called through a minimal serverless **key-proxy** (never ship the API key). |
| **Scope** | **Full parity** — all 158 analyzed flows. |
| **Data / sync** | **SwiftData** canonical store + optional **CloudKit** private-DB sync. **No app backend** (only the AI proxy). |
| **Design** | iOS 26 **Liquid Glass** native look + **original mascot & brand**. App name stays **CalorieBuddy**. |
| **Monetization** | **Standard freemium** — weekly + annual subscriptions with a free trial; Pro gates power features. |
| **Integrations** | Opt-in **HealthKit** mirror + **Sign in with Apple**. Google sign-in dropped (needs a backend). |
| **Build** | Code-only on Windows now; compile later on macOS/Xcode. Deployment target **iOS 26.2**. |

## 2. Vision & users
A friendly, low-friction food diary. The hero loop is **photo → AI recognizes foods & estimates calories/macros → one-tap log**. A cute original mascot + streaks + a gamified "pet" keep users logging daily. Targets people who want to lose/maintain/gain weight without the tedium of manual food search.

**North-star loop:** Open app → see today's calorie budget & rings → tap scan → confirm AI result → watch rings fill & mascot react → keep streak.

## 3. Feature set (free vs Pro)
**Free**
- Onboarding quiz → personalized calorie + macro plan
- Today dashboard (calorie ring, macros, meals)
- AI photo scan — **limited daily scans** (e.g. 3/day)
- Manual food log + edit, basic food/meal detail
- Water tracking, weight logging
- 1 fasting preset, current streak
- HealthKit sync, basic settings

**Pro (paywall)**
- **Unlimited** AI scans + nutrition-label & barcode scan
- Full **stats/history** (trends, weekly/monthly charts)
- Advanced **fasting** presets + history, advanced water goals
- **Customization**: app icons, dashboard backgrounds, mascot themes
- **Awards & nutrition education** library, nutrition score deep-dive
- Plan recalculation, macro fine-tuning

## 4. Information architecture
Root gate: `Onboarding` (until completed) → `Main`.
**Main = Liquid Glass tab bar** with a center scan action:
1. **Today** (dashboard) 2. **Diary** (food log/history per day) 3. **Scan** (center, raised) 4. **Stats** 5. **Settings**
Fasting & Water surface as Today cards + dedicated detail screens. Paywall is modal, triggered by gated actions + post-onboarding.

## 5. Data model (SwiftData, CloudKit-safe — all non-optional props have defaults)
- **UserProfile** — sex, birthDate, heightCm, startWeightKg, currentWeightKg, targetWeightKg, activityLevel, goal, goalPace, dietType, restrictions[], calorieTarget, macroTargets (p/c/f), waterGoalMl, fastingPreset, units, mascotName, onboardingCompleted, createdAt.
- **DiaryDay** — date, consumedKcal, burnedKcal (from HealthKit), waterMl, fastingSessionRef, nutritionScore; relationship → entries.
- **FoodEntry** — id, name, photoData?, mealType (breakfast/lunch/dinner/snack), loggedAt, totalKcal, protein, carbs, fat, fiber, servingDesc, source (aiPhoto/aiLabel/barcode/manual/favorite), confidence; relationship → ingredients.
- **Ingredient** — name, quantity, unit, kcal, protein, carbs, fat, fiber.
- **WaterLog** — date, amountMl, loggedAt.
- **FastingSession** — startAt, endAt?, targetHours, includedLastMeal, state (active/completed/canceled).
- **WeightEntry** — date, weightKg, source.
- **Streak** — current, longest, lastLoggedDate.
- **Award** — key, title, earnedAt (nutrition badges e.g. "Rich in fiber").
- **Favorite/RecentFood** — cached AI/manual items for fast re-log.

## 6. AI scan pipeline
1. Capture (camera) or pick (PHPicker) → downscale/JPEG.
2. POST image (base64) + prompt to **serverless proxy** → proxy calls **Claude vision** with a **strict JSON tool/schema**: `{ items: [{ name, quantity, unit, kcal, protein, carbs, fat, fiber, confidence }], mealType, totalKcal, notes }`.
3. App shows **editable** review (rename, adjust serving, add/remove items, set date/time/meal) → confirm → persist `FoodEntry` + mirror to HealthKit.
4. **Label mode** = OCR/parse a nutrition label; **barcode** (Pro) via Vision. Fallbacks: low confidence → prompt user to edit; offline → manual entry.
5. Model choice: default **Claude Haiku 4.5** for cost/latency, escalate to **Sonnet 4.6** for low-confidence reattempts (configurable in proxy). *(Verify model IDs via the claude-api skill before wiring.)*

## 7. Nutrition math
- **BMR** (Mifflin-St Jeor): male `10w+6.25h−5a+5`, female `10w+6.25h−5a−161`.
- **TDEE** = BMR × activity factor (1.2 sedentary … 1.725 very active).
- **Calorie target** = TDEE ± deficit/surplus from goal & pace (cap pace to a safe ±0.25–1.0 kg/wk; show "realistic target" interstitial like competitor).
- **Macros** = configurable split (default 30P/40C/30F), respecting diet type. Water goal from body weight/activity.

## 8. Monetization
- One **subscription group** with weekly + annual products; annual shows "best value"; intro free trial.
- `SubscriptionStoreView` for the paywall body + custom marketing header (comparison table, testimonials, award badges).
- Single observable **ProEntitlement** from `Transaction.currentEntitlements`; gate via a `.requiresPro()` helper that shows the paywall. Always include **Restore Purchases**.

## 9. Permissions (priming screens before each system prompt)
Camera, Photo Library, Notifications (reminders), HealthKit (read: weight, active energy; write: dietary energy/macros/water, weight), ATT (only if we actually track). Info.plist usage strings via build settings.

## 10. Architecture
- **SwiftUI + Observation** (`@Observable` services in `@Environment`), `NavigationStack` value routing, **MV** pattern (no VM layer; thin services).
- **SwiftData** model container (App-level), CloudKit auto-mirror when entitlement present.
- Services: `AIService`, `HealthKitService`, `StoreService`, `NotificationService`, `NutritionMath`, `AppState/Router`.
- **DesignSystem** module: tokens (color/type/spacing/radii) + reusable components (rings, cards, glass surfaces, buttons, chips, charts).
- Feature folders, each a self-contained set of views. Xcode 26 **synchronized file groups** → new files auto-join the target.

## 11. Risks / mitigations
- **No local compile (Windows):** strict adherence to current APIs; small, composable files; optional macOS CI later. Document any uncertain API in `SETUP.md`.
- **AI key safety:** never in-app; proxy only.
- **CloudKit constraints:** all model attributes have defaults; relationships optional.
- **IP:** original mascot/assets/copy; no BitePal art or names.
- **App Review:** ATT only if tracking; clear subscription terms + restore; HealthKit usage strings.

## 12. Non-goals (v1)
Android/web, social feed, barcode database licensing beyond Vision, Apple Watch app (consider later), meal planning/recipes generation (beyond what onboarding implies).
