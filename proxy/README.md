# CalorieBuddy AI Proxy (OpenRouter)

A serverless Cloudflare Worker that keeps the **OpenRouter** API key off-device and
turns the app's AI requests into structured JSON. The app talks **only** to this proxy.
It owns a data-driven **model registry** (one model per task), forces structured output
per model, normalizes results to the app's frozen wire schema, escalates low-confidence
scans, and enforces per-task quotas + a monthly spend cap.

Design: see [`../docs/adr/`](../docs/adr/) and [`../UBIQUITOUS_LANGUAGE.md`](../UBIQUITOUS_LANGUAGE.md).

## Endpoint

`POST /ai` (the legacy `POST /analyze` path also works). Dispatches on `task`:

| task        | input                                                     | response                          |
| ----------- | --------------------------------------------------------- | --------------------------------- |
| `scan`      | `{ image_base64, hint? }`                                 | `AIScanResult`                    |
| `label`     | `{ image_base64, hint? }`                                 | `AIScanResult` (per-serving)      |
| `nl-parse`  | `{ text }`                                                | `AIScanResult`                    |
| `insights`  | `{ context, scope?: "day"\|"week" }`                      | `{ headline, summary, highlights[], suggestions[] }` |
| `coach`     | `{ messages: [{role,content}], context? }`               | `{ reply }`                       |

Headers: `Content-Type: application/json`, optional `X-App-Secret`, optional `X-Device-Id`
(used as the quota key). Errors are `{ error, code }` with `code` ∈
`bad_request | unauthorized | not_configured | rate_limited | spend_cap | upstream`.

## Deploy (Cloudflare Workers — serverless, scales to zero)

```sh
npm i -g wrangler && wrangler login
cd proxy
wrangler secret put OPENROUTER_API_KEY      # required — your OpenRouter key
wrangler secret put APP_SECRET              # optional shared secret
# Optional, for quotas + spend cap:
wrangler kv namespace create RATE_KV        # then paste the id into wrangler.toml
wrangler deploy
```

Copy the deployed URL (e.g. `https://caloriebuddy-ai-proxy.<you>.workers.dev`) and wire it
into the app as `CB_AI_PROXY_URL` (see `../docs/SETUP.md`). Until set, the app runs the AI
flows in **demo mode** with sample results.

## Models (the registry)

Defaults (verified on OpenRouter 2026-06-21 — slugs drift, re-verify before launch):

| task            | primary                              | fallback                            | output      |
| --------------- | ------------------------------------ | ----------------------------------- | ----------- |
| scan / label    | `qwen/qwen3.5-flash-02-23` (vision)  | `qwen/qwen3-vl-8b-instruct`         | json_schema |
| scan-escalation | `google/gemini-3-flash-preview`      | `google/gemini-3.1-flash-lite-preview` | json_schema |
| nl-parse        | `qwen/qwen3.5-flash-02-23`           | `google/gemini-3.1-flash-lite-preview` | json_schema |
| insights        | `qwen/qwen3.5-flash-02-23`           | `google/gemini-3.1-flash-lite-preview` | json_schema |
| coach           | `google/gemini-3.1-flash-lite-preview` | `qwen/qwen3.5-flash-02-23`        | text        |

`qwen/qwen3.5-flash-02-23` is the cheapest verified vision model with native structured
output (~$0.065/M in). **Pin the dated slug** — bare `qwen/qwen3.5-flash` 404s on the API.

**Prefer Kimi K2?** It's a one-line swap (Kimi K2.5 is multimodal + supports tools, ~6× the
price of Qwen flash):

```toml
# wrangler.toml [vars]
MODEL_NL_PARSE = "moonshotai/kimi-k2.5"
MODEL_INSIGHTS = "moonshotai/kimi-k2.5"
MODEL_COACH    = "moonshotai/kimi-k2.5"
```

Tune anything via env: per-task `MODEL_<TASK>`, full `MODEL_REGISTRY` JSON, `QUOTAS` JSON,
`CONFIDENCE_THRESHOLD`, `MONTHLY_SPEND_CAP_USD`.

## How structured output is forced (portable across models)

Each registry entry has an `outputMode`:
- `json_schema` — `response_format` strict schema + the `response-healing` plugin
  (preferred; every default slug supports it).
- `tool_call` — force one function, read `tool_calls[].function.arguments` (for models that
  do tools but not json_schema, e.g. some Kimi routes).
- `text` — free text (coach).
- `prompt_repair` — extract JSON from prose (last-resort fallback).

`provider.require_parameters: true` is always set for structured modes so OpenRouter won't
silently route to a provider that ignores the schema. The proxy **normalizes** every result
(round ints, clamp confidence, lowercase mealType, sum macros) into the frozen
`AIScanResult` shape — the app decoder never changes.

## Cost & abuse control

> **Safe-by-default.** The worker **refuses to run** (503) unless you set `APP_SECRET` **or**
> bind `RATE_KV`. This prevents an accidental deploy from becoming an open, unlimited proxy in
> front of your paid key. For a throwaway local smoke test only, override with
> `ALLOW_OPEN_PROXY="true"`.

- **Always set an account-level monthly spend limit on openrouter.ai.** That is the real hard
  backstop. The in-worker cap is a *soft* guard: KV is eventually consistent (no atomic
  increment), so it can overshoot slightly under heavy concurrency.
- **Per-task quotas** (need `RATE_KV`) enforce two buckets: the client-sent `X-Device-Id` at
  the task limit, **and** the edge-set client IP at `QUOTA_IP_MULTIPLIER`× the limit. The IP
  bucket is the real ceiling because a device id is client-controlled and can be rotated to
  dodge its own bucket. The app's free 3/day `ScanQuota` is separate UX, not security.
- **Monthly spend cap** (`MONTHLY_SPEND_CAP_USD`, needs `RATE_KV`) is tracked from OpenRouter's
  reported `usage.cost`.
- `APP_SECRET` is shipped in the app binary, so treat it as a low-friction filter that *reduces
  casual abuse*, not as authentication. The IP quota + spend caps are the real controls.

## Local testing (works on Windows, no deploy)

```sh
cd proxy
node test/run.mjs          # unit tests with a mock OpenRouter (no key, no network)
```

See `test/` for the harness. It exercises routing, every output mode, normalization,
escalation, quotas, the spend cap, and error handling.

## Vercel alternative

The logic in `worker.js` is provider-agnostic JS. To run on Vercel Edge, export a `POST`
handler that reads `OPENROUTER_API_KEY` from `process.env`, builds an `env` object, and calls
`handle(request, env)`; supply a KV-like `{get,put}` for quotas (e.g. Vercel KV / Upstash).

## Notes

- CORS is open (`*`); lock it down if a web client is ever added.
- Photos/text are forwarded to OpenRouter only to produce the result; the proxy stores
  nothing except anonymized per-task counters in KV.
