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
- All mascot rendering goes through **`MascotView(mood:size:)`** (`DesignSystem/Components/MascotView.swift`), which renders `Image("mascot-<rawValue>")`.
- **`MascotMood` has 40 poses** — 20 emotions (`happy, excited, proud, sad, sleeping, hungry, love, wink, cool, surprised, thinking, crying, laughing, confused, determined, shy, angry, worried, celebrating, waving`) and 20 activities (`drinking-water, eating-salad, running, weighing, meditating, scanning, cooking, trophy, fire-streak, strong, coffee, measuring, apple, no-junk, thumbs-up, pointing, calendar, target, stretching, phone`).
- Each is a native-transparent PNG imageset in `Assets.xcassets`. Use the contextual poses where they fit: `.drinkingWater` (water), `.scanning` (camera), `.meditating` (fasting), `.fireStreak` (streak), `.eatingSalad`/`.weighing`/`.target`/`.calendar`/`.celebrating` (onboarding), etc.
- Every pose was vision-verified to match its label; regenerate any single one by editing `MOODS` in `assets/brand/generate.py` (keep the sticker style + character description) and rerunning.

## App icon
- Concept: Pip's face on a sprout-green rounded square, or a minimalist fox-ear + leaf mark.
- Add a 1024×1024 PNG to `Assets.xcassets/AppIcon.appiconset`.
- Alternate icons (Mint / Berry / Night) are surfaced in Settings → App icon; declare them under `CFBundleAlternateIcons` (build settings) and add their assets to enable.

## Producing the artwork (done)
The mascot + app icon were generated via fal **Ideogram V3 `generate-transparent`** — native transparent PNGs, so **no background-removal step and clean edges**. They live in `Assets.xcassets`. Method (see `assets/brand/generate.py`, needs `FAL_KEY`):
1. A fixed, detailed character description (`CHAR`) + a per-mood pose, with `expand_prompt: false` and the **same `seed`** for every mood — that's what keeps all moods looking like the same fox without a reference image (the endpoint has no reference-image input).
2. Each call returns a transparent PNG; it's alpha-trimmed to the artwork and resized to 512px → `mascot-<mood>.imageset`.
3. App icon: a transparent fox **face** composited onto a solid sprout-green square (edge-to-edge, opaque, 1024px).

To regenerate or add a mood: edit the `MOODS` dict in `generate.py`, add the matching `case` to `MascotMood`, and rerun (overwrites in place). Keep the same `SEED` so the new pose matches.
