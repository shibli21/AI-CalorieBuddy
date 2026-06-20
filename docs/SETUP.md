# CalorieBuddy — Setup & Build

You're developing on **Windows**, but iOS apps build only on **macOS + Xcode**. All Swift code is written here; do the steps below on a Mac (or cloud Mac) to compile, run, and ship.

## 1. Prerequisites (on the Mac)
- macOS with **Xcode 26.3+** (iOS 26.2 SDK).
- Apple Developer account (team `BW8FTW54W5` is already in the project; change `DEVELOPMENT_TEAM` / `PRODUCT_BUNDLE_IDENTIFIER` if needed).
- Open `CalorieBuddy.xcodeproj` (no SPM/CocoaPods needed for v1 — all native frameworks).

## 2. Enable capabilities (Signing & Capabilities tab)
The repo ships `CalorieBuddy/CalorieBuddy.entitlements` and the matching build setting. In Xcode confirm/add:
- **HealthKit** (enables `com.apple.developer.healthkit`).
- **iCloud → CloudKit**, create container `iCloud.shibli21.CalorieBuddy` (or rename to match your bundle id; update the entitlement + `AppContainer`).
- **Sign in with Apple**.
- **Push Notifications** are NOT required (reminders are local notifications).
> If a capability isn't provisioned yet, Xcode's "Automatically manage signing" will register it on first build. CloudKit needs the container to exist in the CloudKit dashboard.

## 3. Info.plist usage strings
Provided via build settings (`INFOPLIST_KEY_*`): camera, photo library, HealthKit share/update, user tracking. Edit copy in the target build settings if you want different wording.

## 4. AI proxy (Claude vision)
The app never holds the Anthropic key. Deploy the proxy in `proxy/` (see its README — Cloudflare Worker / Vercel function):
1. Set env `ANTHROPIC_API_KEY` on the host.
2. Deploy; note the URL.
3. In the app, set `AIConfig.proxyBaseURL` (or the `CB_AI_PROXY_URL` build setting / `Secrets.xcconfig`) to that URL.
4. Optional: app-level shared secret header to stop abuse.
- Default model: **Claude Haiku 4.5**; low-confidence retries escalate to **Sonnet 4.6**. Confirm exact model IDs with the `claude-api` reference before going live.

## 5. StoreKit (local testing)
- `Configuration.storekit` is included with sample weekly/annual products + a free trial.
- Scheme → Run → Options → **StoreKit Configuration** → select it to test purchases without App Store Connect.
- For production, create the subscription group + products in App Store Connect with the same product ids (`com.shibli21.caloriebuddy.pro.weekly`, `...pro.annual`).

## 6. Run
- Select an iOS 26 simulator or a device. **Liquid Glass specular/motion only renders on device** — test glass on hardware.
- First launch starts in onboarding; complete it to reach the main app. Use Settings → (debug) reset to replay onboarding.

## 7. Project conventions
- Files live under `CalorieBuddy/` with **synchronized file groups** — adding a `.swift` file to the folder automatically adds it to the target (no pbxproj editing).
- Asset catalog: `CalorieBuddy/Assets.xcassets`. Mascot/brand art lands here once generated.
