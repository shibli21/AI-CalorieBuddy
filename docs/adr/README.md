# Architecture Decision Records

Short records of the consequential, hard-to-reverse decisions behind CalorieBuddy's
AI system. Each ADR states the context, the decision, and what it commits us to.

These were produced during a design "grilling" on 2026-06-21 (see the companion
glossary at `../../UBIQUITOUS_LANGUAGE.md`).

| #    | Decision                                                                 | Status   |
| ---- | ------------------------------------------------------------------------ | -------- |
| 0001 | [OpenRouter as the AI backend, behind the serverless proxy](0001-openrouter-backend.md) | Accepted |
| 0002 | [Model-agnostic, task-routed model registry in the proxy](0002-model-registry-in-proxy.md) | Accepted |
| 0003 | [Portable structured output, normalized to a frozen schema](0003-portable-structured-output.md) | Accepted |
| 0004 | [Cost-optimized model split (cheap vision + escalation; Kimi K2 text)](0004-cost-optimized-model-split.md) | Accepted |
| 0005 | [Cost & abuse control via proxy-side quotas and a spend cap](0005-proxy-quotas-and-spend-cap.md) | Accepted |
| 0006 | [AI feature scope: scan, label, NL entry, insights, coach](0006-ai-feature-scope.md) | Accepted |
