# CalorieBuddy — Brand System

Original brand, inspired by but legally distinct from the analyzed competitor. **Do not reuse BitePal's raccoon, colors, or copy.**

## Name & voice
- **App name:** CalorieBuddy
- **Mascot:** **Pip**, an original friendly **fox** — warm, encouraging, a little playful. Pip cheers you on, never shames. Copy is short, kind, second-person ("Nice one!", "You've got this").

## Palette (source of truth: `CalorieBuddy/DesignSystem/Theme.swift`)
| Token | Hex | Use |
|---|---|---|
| Accent (Sprout) | `#2FBF71` | primary actions, calorie ring |
| Accent Deep | `#1E9E59` | gradients, pressed |
| Berry | `#FF5A7E` | protein, destructive, over-goal |
| Amber | `#FFB23E` | carbs, warnings |
| Sky | `#4DA8FF` | fat |
| Grape | `#8B7CF6` | fasting |
| Water | `#33B6E6` | hydration |
| Ink | `#14141A` / dark `#F5F5F7` | text |
| Background | `#FBF8F3` / dark `#0D0D11` | app background |
| Surface | `#FFFFFF` / dark `#1A1A21` | cards |

## Typography
- **Family:** SF Rounded (`.system(design: .rounded)`) throughout — friendly, legible.
- **Scale:** see `DesignSystem/Typography.swift`. Hero numerals use the fixed-size `CBFont.display`.

## Mascot rendering
- All mascot rendering goes through **`MascotView(mood:size:)`** (`DesignSystem/Components/MascotView.swift`).
- Moods: `happy, excited, sleeping, sad, proud, hungry`.
- Currently emoji placeholders. To ship real art, add illustrated PNGs/SVGs named `mascot-happy`, `mascot-excited`, etc. (or an asset per mood) to `Assets.xcassets` and switch `MascotView.body` to `Image(mood.assetName)`.

## App icon
- Concept: Pip's face on a sprout-green rounded square, or a minimalist fox-ear + leaf mark.
- Add a 1024×1024 PNG to `Assets.xcassets/AppIcon.appiconset`.
- Alternate icons (Mint / Berry / Night) are surfaced in Settings → App icon; declare them under `CFBundleAlternateIcons` (build settings) and add their assets to enable.

## Producing the artwork
The brand **system** (palette, type, mascot abstraction, naming) is in code now. To generate the actual illustrated mascot sheet + app icon, run an image-generation pass (e.g. the `brandkit` or `imagegen-frontend-mobile` skill) to this spec:
- A friendly, rounded, flat-illustration fox named Pip, sprout-green accents, warm cream background, expressive but simple — in the six moods above, plus a 1024px app-icon lockup.
- Export transparent PNGs at @1x/@2x/@3x and drop them into the asset catalog; `MascotView` and the launch/welcome screens pick them up.
