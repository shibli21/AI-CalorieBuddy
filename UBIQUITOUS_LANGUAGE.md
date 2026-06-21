# Ubiquitous Language

The shared vocabulary for CalorieBuddy's AI system. Use these terms (and avoid the listed
aliases) in code, comments, ADRs, and conversation so "model", "feature", and "endpoint"
don't blur together. Decisions that use these terms live in `docs/adr/`.

## AI routing

| Term            | Definition                                                                                          | Aliases to avoid              |
| --------------- | -------------------------------------------------------------------------------------------------- | ----------------------------- |
| **Task**        | The unit of AI work the app requests, identified by a string (`scan`, `label`, `nl-parse`, `insights`, `coach`). The proxy routes on it. | use-case, feature, endpoint, intent |
| **Proxy**       | The serverless Cloudflare Worker that holds the provider key and fronts OpenRouter. The only backend the app talks to. | server, backend, API          |
| **Provider**    | The upstream that actually runs a model (OpenRouter, and behind it Google/Moonshot/etc.).           | vendor, host                  |
| **Registry**    | The proxy-owned, env-overridable map `task → model entry`. The single source of truth for model selection. | config, model map, settings   |
| **Model entry** | A registry value: `{ primary, fallback, vision, outputMode, maxTokens }`.                           | —                             |
| **Model slug**  | An OpenRouter model id (e.g. `moonshotai/kimi-k2.5`). Volatile data, never hard-coded in app code.  | model name, model id          |

## Output & reliability

| Term             | Definition                                                                                       | Aliases to avoid          |
| ---------------- | ----------------------------------------------------------------------------------------------- | ------------------------- |
| **outputMode**   | How a given model is forced to return JSON: `json_schema`, `tool_call`, or `prompt_repair`.      | format, schema mode       |
| **Normalization**| Proxy step that coerces any model's output into the frozen wire schema (round ints, clamp confidence, fix enum casing, sum macros). | cleanup, sanitizing       |
| **Wire schema**  | The frozen JSON contract between proxy and app (`AIScanResult` / `AIScanItem`, etc.). Changing it would force an app release, so it stays stable. | response, payload, DTO    |
| **Escalation**   | Retrying a low-confidence **scan** on a stronger vision model (`scan` → `scan-escalation`).      | retry, upgrade, fallback  |
| **Fallback**     | Switching to the entry's backup model on *error* (bad JSON, 404 slug, provider outage). Distinct from escalation, which is about *confidence*. | retry, escalation         |
| **Confidence**   | The model's self-reported 0–1 certainty for a scan; drives escalation and the review-screen warning. | accuracy, score           |

## Cost & limits

| Term            | Definition                                                                                  | Aliases to avoid        |
| --------------- | ------------------------------------------------------------------------------------------ | ----------------------- |
| **Quota**       | A proxy-enforced per-caller, per-task rate limit (the real cost boundary).                  | limit, throttle         |
| **ScanQuota**   | The *client-side* free-tier counter (3 scans/day, UserDefaults). UX only — not a security boundary. | scan limit              |
| **Spend cap**   | The proxy's hard monthly ceiling on estimated provider spend; backstopped by OpenRouter's account limit. | budget, billing limit   |
| **Caller**      | The identity a quota is keyed to (`X-App-Secret` + optional device id).                     | user, client, device    |

## Features (the tasks, in product terms)

| Term             | Definition                                                                          | Aliases to avoid     |
| ---------------- | ---------------------------------------------------------------------------------- | -------------------- |
| **Scan**         | Meal **photo** → structured nutrition. The hero loop. Vision.                       | snap, capture        |
| **Label scan**   | Nutrition-**label** photo → per-serving nutrition. Vision, Pro.                     | OCR                  |
| **NL entry**     | Typed meal **description** → structured items, reusing the review screen. Text.      | text scan, quick add |
| **Insights**     | AI **summaries/highlights** over the user's logged data. Text.                      | tips, analytics      |
| **Coach**        | Conversational nutrition **assistant** with history + disclaimers. Text, Pro.       | chat, assistant, bot |

## Relationships

- A **Task** resolves through the **Registry** to a **Model entry**, which names a **Model
  slug** on a **Provider** via the **Proxy**.
- Each **Model entry** declares an **outputMode**; the proxy applies **Normalization** to fit
  the **Wire schema**.
- **Scan** uses **Confidence** to trigger **Escalation**; any task uses **Fallback** on error.
- Every **Task** is bounded by a **Quota** and the global **Spend cap**, keyed by **Caller**.

## Example dialogue

> **Dev:** "The coach is returning prose sometimes. Do I change the app decoder?"
>
> **Domain expert:** "No — the **wire schema** is frozen. Coach replies are free text anyway;
> only structured **tasks** like **scan** and **nl-parse** need JSON. If a JSON task drifts,
> fix its **outputMode** or **normalization** in the **proxy**, not the app."
>
> **Dev:** "Kimi K2.5 doesn't honor `json_schema`. So for **nl-parse** I set its **outputMode**
> to `tool_call`?"
>
> **Domain expert:** "Right — force the function and read `tool_calls`. If a **model slug** ever
> 404s, the entry's **fallback** takes over; that's separate from **escalation**, which only
> fires on low **confidence** during a **scan**."
>
> **Dev:** "And limits?"
>
> **Domain expert:** "**ScanQuota** is just UX. The real ceiling is the per-task **quota** and
> the monthly **spend cap**, both in the **proxy**, keyed by **caller**."

## Flagged ambiguities

- **"fallback" vs "escalation"** were used interchangeably. They are distinct: *escalation*
  is confidence-driven (scan only); *fallback* is error-driven (any task).
- **"quota"** meant two things. The durable cost boundary is the proxy **Quota**; the
  client free-tier counter is **ScanQuota** (UX only).
- **"use-case" / "feature" / "endpoint"** all meant the routing unit. Canonical term: **Task**.
  There is one HTTP endpoint; it dispatches on the task.
