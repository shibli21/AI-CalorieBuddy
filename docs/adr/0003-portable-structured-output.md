# 0003 — Portable structured output, normalized to a frozen schema

- **Status:** Accepted (2026-06-21)

## Context

The whole pipeline depends on getting back **strict JSON** (`AIScanResult` /
`AIScanItem`, and analogous shapes for insights). Anthropic achieved this with forced
`tool_use`. That exact mechanism is **not portable**: across OpenRouter models, support for
`response_format: json_schema` and for OpenAI-style `tools`/`tool_choice` **varies per model
and per provider route**. Different models also emit subtly different JSON (decimals vs ints,
missing fields, enum casing).

## Decision

**Three things:**

1. **Per-model output mode.** Each registry entry declares an `outputMode`:
   - `json_schema` — `response_format: {type:"json_schema", json_schema:{strict:true,…}}`
     (preferred where supported: OpenAI, Gemini, many open models).
   - `tool_call` — force one function via `tools` + `tool_choice`; read
     `choices[0].message.tool_calls[0].function.arguments` (the closest 1:1 port of the old
     Anthropic approach; used for Kimi K2 and others that do tools but not json_schema).
   - `prompt_repair` — schema embedded in the prompt; extract the JSON object from the text,
     then validate/repair (universal last resort).

2. **Frozen wire schema.** The JSON the app receives (`AIScanResult` shape) does **not**
   change. The Swift decoder stays as-is. The proxy is responsible for producing that shape.

3. **Server-side normalization.** Whatever the model returns, the proxy normalizes to the
   canonical schema before responding: round numbers to ints, clamp `confidence` to 0–1,
   lowercase `mealType` into the 4-value enum, sum item macros when totals are missing.

A retry ladder backs this up (see ADR 0004): bad/instructed-but-malformed JSON triggers one
same-model retry, then a fallback model.

## Consequences

- We can use the cheapest viable model per task even if its structured-output support is
  weaker, because the proxy adapts and validates.
- The app's defensive decoder (`flexInt`, item-sum fallback) is a second safety net, not the
  primary guarantee.
- New tasks must define their schema + normalizer in the proxy; this is the cost of keeping
  the client dumb and stable.
