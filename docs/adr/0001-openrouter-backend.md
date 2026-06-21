# 0001 — OpenRouter as the AI backend, behind the serverless proxy

- **Status:** Accepted (2026-06-21)
- **Supersedes:** the Anthropic-direct implementation in `proxy/worker.js`

## Context

The app shipped one AI path: app → Cloudflare Worker → **Anthropic** Claude vision →
`AIScanResult`. We want (a) cheaper models, (b) the freedom to pick a different model
per feature, and (c) access to many providers without re-integrating each one. SPEC §1/§11
forbids shipping any provider key inside the app.

OpenRouter is a single OpenAI-compatible endpoint that fronts 400+ models across providers,
with one key, unified billing, per-request model selection, and built-in fallback routing.

## Decision

Route all cloud AI through **OpenRouter** (`https://openrouter.ai/api/v1/chat/completions`),
called from the **existing serverless proxy** (Cloudflare Worker). The proxy holds the single
`OPENROUTER_API_KEY`. The app remains a pure client that knows only the proxy URL and an
optional shared secret.

The Cloudflare Worker **is** serverless — no server to run, scales to zero, one-command
deploy. It is kept (not removed) because:

1. **Key safety** — an OpenRouter key in the binary can be extracted and used to drain
   credits. Hard rule (SPEC §11).
2. **Server-owned routing** — the model registry, escalation, normalization, and quotas
   must live somewhere the client can't tamper with (see ADR 0002, 0005).
3. **No app release to retune** — changing models/providers is a proxy config edit.

## Consequences

- The proxy's request builder and response parser are **rewritten** from Anthropic's wire
  format (`x-api-key`, `anthropic-version`, image blocks, `tool_use`) to OpenRouter's
  OpenAI-compatible schema (`Authorization: Bearer`, `image_url` parts, `tool_calls` /
  `response_format`).
- The app's `AIScanResult` JSON shape is **frozen** so the Swift decoder is untouched
  (see ADR 0003).
- We depend on OpenRouter availability/pricing; mitigated by fallback models (ADR 0002)
  and the option to point `OPENROUTER_*` at any OpenAI-compatible host later.
- Developing on Windows is fine: the JS proxy is testable locally (node + a mock OpenRouter)
  even though the iOS app needs a Mac to build.
