# 0005 — Cost & abuse control via proxy-side quotas and a spend cap

- **Status:** Accepted (2026-06-21)

## Context

Cheap models invite more usage, and the feature set now includes an **unbounded** surface
(coach chat). The existing scan limit is a **client-side** `ScanQuota` (UserDefaults, 3/day)
— fine as UX, but trivially bypassed and therefore useless as a cost ceiling. With a real
provider key behind the proxy, abuse maps directly to money.

## Decision

Enforce limits **at the proxy**, per task:

- **Per-caller, per-task rate limits** keyed by a caller identity (the `X-App-Secret` and/or
  a device id header), with sensible defaults per task (e.g. scans/day, coach messages/hour,
  insight generations/day). Configurable via env.
- A **hard monthly spend cap** tracked by the proxy (estimated from token usage returned by
  OpenRouter), plus the OpenRouter account-level spend limit as a backstop. When the cap is
  hit the proxy returns a clean, typed error the app can show gracefully.
- The client-side `ScanQuota` **stays** as fast UX feedback for the free tier, but is no
  longer the security boundary.

Counters use Cloudflare KV (or an equivalent durable store) keyed by caller+task+window;
they degrade safe (fail-closed on the spend cap, fail-open-with-logging on transient KV
errors so a KV blip doesn't break the hero feature).

## Consequences

- A single leaked/abused secret can't run up an unbounded bill.
- Adds a state dependency (KV) and a small amount of latency/cost per request.
- Quotas are per-task, so the cheap scan and the expensive coach can have different limits.
- New tasks must declare a default limit, or they inherit a conservative global default.
