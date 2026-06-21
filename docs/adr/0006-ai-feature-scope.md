# 0006 — AI feature scope: scan, label, NL entry, insights, coach

- **Status:** Accepted (2026-06-21)

## Context

"Finish all the AI features." Per SPEC §6 the only AI v1 goals were photo **scan** and
**label** mode (both already coded but dormant). NL entry, insights, and coach were not in
spec or code. With cheap text models now in play (ADR 0004), the owner opted to build the
full set. This ADR records the agreed scope so it isn't re-litigated.

## Decision

Ship these AI tasks (all routed through the proxy registry, ADR 0002):

1. **scan** (vision) — meal photo → `AIScanResult`. Make the existing path live on
   OpenRouter. *Baseline.*
2. **label** (vision) — nutrition-label photo → per-serving `AIScanResult`. Same path, Pro-
   gated (existing `ProFeature.labelScan`).
3. **nl-parse** (text) — "two eggs and toast" → `AIScanResult` items, reusing the existing
   review/edit screen (`ScanReviewView`). The natural job for cheap Kimi K2 text.
4. **insights** (text) — a daily AI summary on the Diary day view and a weekly AI summary on
   Stats, fed by the user's logged data; **user-initiated** and **cached with a data
   fingerprint** to avoid re-spend and stale output. Meal-detail "highlights" remain the
   existing **algorithmic** Awards (`NutritionScore` / `NutritionAward`), not an LLM call —
   deliberately out of AI scope for v1.
5. **coach** (text) — conversational nutrition assistant with persisted history, context from
   profile/diary, **per-user quota** (ADR 0005), and a "not medical advice" disclaimer.

### Guardrails carried across all text features
- **Demo/offline fallback** stays: unconfigured or offline → deterministic sample output in
  DEBUG, typed `notConfigured` error in release (mirrors the scan path). No fabricated data
  silently shown as real.
- Coach is **Pro-gated** and disclaims medical advice (the app already states it's not a
  medical device).

## Consequences

- Kimi K2 (text) now has real jobs (3, 4, 5), justifying the cost-optimized split.
- Scope is bounded: explicitly **out** of scope are barcode (Apple Vision, licensed DB —
  SPEC non-goal), recipe/meal-plan generation, and any on-device model migration (would need
  an iOS 27 floor; current floor is iOS 26 — see `docs/ios26-notes.md`).
- Each new task needs: a registry entry, a proxy schema+normalizer, a thin `AIService`
  method, a client quota default, and UI. Tracked as separate build tasks.
