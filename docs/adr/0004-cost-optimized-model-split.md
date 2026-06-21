# 0004 — Cost-optimized model split (cheap vision + escalation; Kimi K2 text)

- **Status:** Accepted (2026-06-21)

## Context

The user's intent is "cheap models (Kimi K2 / anything cheap)." Two facts (verified
2026-06-21) shape the split:

1. The **hero feature is vision** — both scan modes (meal + label) send an image. The model
   *must* be multimodal. Recent **Kimi K2.x (K2.5/K2.6/K2.7) are multimodal**, so Kimi *can*
   see — but at ~$0.4–0.6/M input it is **not** the cheapest vision option. Dedicated cheap
   vision models (Gemini Flash-Lite class, Qwen-VL class) undercut it several-fold.
2. **Text features** (NL entry, insights, coach) don't need vision, and a cheap text model
   (Kimi K2) is an excellent, inexpensive fit.

Calorie accuracy is the product's core value, so the scan can't be made *too* cheap.

## Decision

Default the registry to a **split**:

- **scan** → a cheap **vision** model, with **confidence escalation**: if overall confidence
  `< CONFIDENCE_THRESHOLD` (default 0.6), retry once on a **stronger vision** model
  (`scan-escalation`). This ports the old Haiku→Sonnet philosophy to vision tiers.
- **nl-parse / insights / coach** → a cheap **text** model (**Kimi K2**), no vision.

Exact slugs live in the registry as data (ADR 0002) and are verified at build time, because
slugs/prices drift. The split is a **default**, not a lock-in: any task's model is a config
edit away, including "use one multimodal Kimi K2.7 for everything" if simplicity is later
preferred over per-task cost.

## Consequences

- Cheapest sustainable cost while protecting scan accuracy via escalation.
- Two model "families" to keep healthy (vision + text); the registry + fallbacks (ADR 0002)
  absorb individual model outages.
- Image tokens dominate scan cost (a 1024px photo ≈ 1.3k tokens), so the client keeps
  downscaling uploads (`jpegForUpload`, ~1024px) — that stays a real cost lever.
- Escalation can ~2× the cost of a low-confidence scan; bounded because it fires only below
  threshold and only once.
