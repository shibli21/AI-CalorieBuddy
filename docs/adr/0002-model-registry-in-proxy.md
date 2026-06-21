# 0002 — Model-agnostic, task-routed model registry in the proxy

- **Status:** Accepted (2026-06-21)

## Context

We want "a generic system where I can choose any model for each use case." Today model
choice is a single `MODEL` env var plus one escalation pair, hard-coded for one feature.
A generic system needs to map *each feature* to *its own* model(s), and let that mapping
change without an app release. Model slugs on OpenRouter also change/deprecate often, so the
mapping must be **data, not code**.

## Decision

The proxy owns a **registry**: a map from **task** (a.k.a. use-case) to a model entry.

```
task → { primary, fallback, vision, outputMode, maxTokens }
```

- The app sends only a **`task`** string (e.g. `"scan"`, `"nl-parse"`, `"insights"`,
  `"coach"`) plus that task's input. It never names a model.
- The registry has a built-in default and is **overridable via env** (`MODEL_REGISTRY` JSON,
  or per-task `MODEL_SCAN`, `MODEL_COACH`, … overrides) so models are tuned by editing
  config and redeploying — no binary change.
- Unknown slugs **fail soft**: the proxy falls back to the entry's `fallback`, then to a
  known-good default, rather than 500-ing the hero feature.

The unit of configuration is the **task**, not an HTTP route — one `/analyze`-style endpoint
dispatches on `task`, keeping the surface small.

## Consequences

- Adding a feature = adding a task entry + a thin client call; no new endpoint, no new auth.
- The client cannot pick an expensive model (cost-safe); the trade-off is that genuinely
  client-driven model choice would need an explicit, secret-gated override (deliberately not
  built for v1).
- The registry is the single source of truth for "which model, which output mode, vision or
  not" — consumed by ADR 0003 (output handling) and ADR 0004 (the concrete slugs).
- See `UBIQUITOUS_LANGUAGE.md` for the canonical definitions of **task**, **registry**,
  **outputMode**, and **escalation**.
