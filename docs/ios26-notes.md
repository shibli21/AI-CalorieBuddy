# CalorieBuddy — iOS 26/27 Technical Notes

Captured June 2026, grounded in current Apple docs + ecosystem sources (links at bottom).
This is the research backing the build decisions in `SPEC.md`.

## Platform / deployment-target context
- **iOS 26 (Sept 2025):** Liquid Glass design language; Foundation Models framework (on-device, **text-only** at launch) with `@Generable` structured output + tool calling; SwiftData; StoreKit 2 SwiftUI views.
- **iOS 27 (WWDC26, June 2026):** Foundation Models gains **image input** (multimodal) and can call **Vision** tools (OCR, barcode) on-device; framework **opened to any LLM provider** behind the same API.
- **Impact:** free/private/offline on-device *photo→food* recognition needs an **iOS 27** floor. With an **iOS 26** floor, the camera feature must use a **cloud multimodal LLM** or a **nutrition SDK**.

## Liquid Glass (HIG + SwiftUI)
- Native SwiftUI controls adopt Liquid Glass **automatically** when compiled against the iOS 26 SDK (toolbars/tab bars float on glass, adapt to content beneath).
- APIs: `.glassEffect(_:in:)` (default `.regular`, default shape `Capsule`); `GlassEffectContainer` to merge/morph multiple glass shapes with a shared sampling region; scroll-edge effects.
- **Test on device** — the simulator does not render specular highlights/motion.
- Strategy: rely on native components first; add custom glass sparingly for hero elements (calorie ring, floating scan button, paywall).

## AI food recognition — options
- **Apple Foundation Models** — on-device, free, private, offline, structured output (`@Generable`), tool calling. Image input = **iOS 27+**. ~3B model → great for text (NL meal entry, tips, parsing); precise calorie estimation from a photo is risky as the *sole* source.
- **Cloud multimodal LLM (Anthropic Claude vision)** — photo → foods + per-item calorie/macro estimate as structured JSON. High quality, fully promptable; needs network, per-scan cost, and a **secure key** (lightweight proxy / backend recommended; never ship the key in the app).
- **Passio Nutrition-AI SDK** — purpose-built: on-device **+** cloud food recognition, **2.5M-item** nutrition DB, **barcode + nutrition-label** scan, serving-size estimation. Token pricing ~**$2.50/M tokens** (volume discounts). Best turnkey accuracy/offline; adds an SDK dependency.
- **Vision framework** — generic image classification + OCR/barcode; not nutrition-aware alone (useful as a helper for label/barcode).
- **Recommendation:** MVP via **cloud LLM (Claude)** for speed/flexibility, *or* **Passio** if you want best accuracy + barcode + offline out of the box. Use on-device Foundation Models for text features regardless (and migrate the camera on-device if/when iOS 27 is the floor).

## HealthKit
- Write `dietaryEnergyConsumed` + macros (`dietaryProtein`/`dietaryCarbohydrates`/`dietaryFatTotal`) + `dietaryWater`; write/read `bodyMass` (weight); read `activeEnergyBurned`/steps to inform the daily budget.
- Per-type authorization; Info.plist usage strings required; observer queries + background delivery for sync.
- Recommend: SwiftData is the **canonical store**; mirror nutrition/weight/water to HealthKit (opt-in).

## StoreKit 2 / paywall
- `SubscriptionStoreView` renders a full paywall for one subscription group (plan picker, CTA, terms, restore). iOS 26 added `SubscriptionOfferView` (upgrade/downgrade/crossgrade merchandising).
- Gate features via `Transaction.currentEntitlements`; expose a single observable `ProEntitlement`.
- Always include **Restore Purchases**; use a `.storekit` test config in Xcode.

## Permissions / onboarding
- **ATT:** request only when genuinely tracking across other apps (review-sensitive). Camera (`AVCaptureDevice`) + Photos (`PHPicker`) for scanning; notifications for meal/fasting reminders. All need Info.plist usage strings.
- Onboarding quiz → compute calorie target via **Mifflin-St Jeor** BMR × activity factor (TDEE), then adjust for goal + chosen pace.
- **Prime** each permission with a context screen before the system prompt (the competitor does this throughout).

## Recommended architecture
- SwiftUI + **Observation** (`@Observable`), `NavigationStack` value-based routing, `@Environment` for shared services.
- **SwiftData** models; optional **CloudKit** private-DB sync.
- Feature-folder modular structure; **MV** pattern (no heavyweight VM layer) with thin service objects (AI, HealthKit, Store, Notifications).

## Sources
- Apple — Foundation Models framework: https://www.apple.com/newsroom/2025/09/apples-foundation-models-framework-unlocks-new-intelligent-app-experiences/
- WWDC26 — What's new in the Foundation Models framework: https://developer.apple.com/videos/play/wwdc2026/241/
- WWDC26 — What's new in image understanding: https://developer.apple.com/videos/play/wwdc2026/237/
- Foundation Models image input (iOS 27): https://blakecrosley.com/blog/foundation-models-image-input-ios-27
- SwiftUI Liquid Glass guide: https://www.atelier-socle.com/en/articles/swiftui-liquid-glass-guide
- GlassEffectContainer: https://dev.to/arshtechpro/understanding-glasseffectcontainer-in-ios-26-2n8p
- Passio Nutrition-AI iOS SDK: https://passio.gitbook.io/nutrition-ai/mobile-sdks/ios-sdk-docs
- StoreKit views / SubscriptionStoreView paywall: https://www.revenuecat.com/blog/engineering/storekit-views-guide-paywall-swift-ui/
