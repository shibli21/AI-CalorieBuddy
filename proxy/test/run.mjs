// CalorieBuddy AI proxy — local test harness (Windows-friendly, no network, no key).
//
//   node test/run.mjs
//
// Exercises routing, every output mode, normalization, escalation, fallback,
// non-retryable errors, quotas, the spend cap, and request handling, using a
// MOCK OpenRouter (real Request/Response from the Node runtime, fake fetch + KV).
// Requires Node 18+ (global fetch/Request/Response/URL).

import {
  handle, runTask, buildPayload, buildMessages, normalizeScanResult, normalizeInsight,
  parseStructured, extractJSON, estimateCostUSD, inferTask, callerKey, ipKey, getRegistry,
} from "../worker.js";

// ---------------------------------------------------------------------------
// Tiny test runner
// ---------------------------------------------------------------------------
let passed = 0, failed = 0;
const fails = [];
function ok(cond, msg) { if (cond) { passed++; } else { failed++; fails.push(msg); console.error("  ✗ " + msg); } }
function eq(a, b, msg) { ok(a === b, `${msg} (got ${JSON.stringify(a)}, want ${JSON.stringify(b)})`); }
function approx(a, b, msg) { ok(Math.abs(a - b) < 1e-9, `${msg} (got ${a}, want ${b})`); }
async function test(name, fn) { try { await fn(); console.log("✓ " + name); } catch (e) { failed++; fails.push(`${name}: ${e.message}`); console.error("✗ " + name + " — " + e.stack); } }

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
// ALLOW_OPEN_PROXY so the keyless/KV-less unit tests aren't blocked by the
// safe-by-default open-proxy guard (which is exercised separately below).
const BASE_ENV = { OPENROUTER_API_KEY: "test-key", ALLOW_OPEN_PROXY: "true" };
const FIXED_NOW = () => 1_750_000_000_000; // fixed ms so quota buckets / month keys are stable

// Build a mock fetch from a responder(payload, callIndex) -> {status?, body} | {throw}
function makeFetch(responder) {
  const calls = [];
  const fn = async (url, opts) => {
    const payload = JSON.parse(opts.body);
    calls.push({ url, payload });
    const r = responder(payload, calls.length - 1);
    if (r && r.throw) throw new Error(r.throw);
    return new Response(JSON.stringify(r.body), { status: r.status ?? 200 });
  };
  fn.calls = calls;
  return fn;
}

// In-memory KV with the Cloudflare get/put surface.
function makeKV() {
  const store = new Map();
  return {
    store,
    async get(k) { return store.has(k) ? store.get(k) : null; },
    async put(k, v) { store.set(k, String(v)); },
  };
}

// OpenRouter response builders.
const usage = (cost = 0.001) => ({ prompt_tokens: 100, completion_tokens: 50, total_tokens: 150, cost });
function schemaResp(obj, { model = "qwen/qwen3.5-flash-02-23", finish = "stop", cost } = {}) {
  return { status: 200, body: { model, choices: [{ finish_reason: finish, message: { content: JSON.stringify(obj) } }], usage: usage(cost) } };
}
function toolResp(obj, { name = "log_nutrition", model = "moonshotai/kimi-k2.5", finish = "tool_calls", cost } = {}) {
  return { status: 200, body: { model, choices: [{ finish_reason: finish, message: { tool_calls: [{ function: { name, arguments: JSON.stringify(obj) } }] } }], usage: usage(cost) } };
}
function textResp(text, { model = "google/gemini-3.1-flash-lite-preview", finish = "stop", cost } = {}) {
  return { status: 200, body: { model, choices: [{ finish_reason: finish, message: { content: text } }], usage: usage(cost) } };
}
function errResp(status, message = "boom") { return { status, body: { error: { code: status, message } } }; }

const VALID_SCAN = {
  title: "Eggs & toast", mealType: "Breakfast",
  items: [{ name: "Egg", quantity: 2, unit: "egg", kcal: 140.6, protein: 12, carbs: 1, fat: 10, fiber: 0, confidence: 0.9 }],
  totalKcal: 141, totalProtein: 12, totalCarbs: 1, totalFat: 10, totalFiber: 0, confidence: 0.9, notes: "",
};

function req(path, { method = "POST", body, headers = {} } = {}) {
  const url = `https://proxy.test${path}`;
  const init = { method, headers };
  if (method !== "GET" && method !== "OPTIONS") init.body = typeof body === "string" ? body : JSON.stringify(body ?? {});
  return new Request(url, init);
}

// ===========================================================================
console.log("\n— pure helpers —");

await test("inferTask", () => {
  eq(inferTask({ task: "coach" }), "coach", "explicit task wins");
  eq(inferTask({ mode: "label" }), "label", "label mode");
  eq(inferTask({ image_base64: "x" }), "scan", "image -> scan");
  eq(inferTask({ text: "2 eggs" }), "nl-parse", "text -> nl-parse");
  eq(inferTask({}), "scan", "default scan");
});

await test("buildMessages: scan has text-before-image data URI", () => {
  const m = buildMessages("scan", { image_base64: "ABC", hint: "lunchbox" });
  eq(m[0].role, "system", "system first");
  eq(m[1].content[0].type, "text", "text part first");
  eq(m[1].content[1].type, "image_url", "image part second");
  ok(m[1].content[1].image_url.url.startsWith("data:image/jpeg;base64,ABC"), "data URI format");
  ok(m[1].content[0].text.includes("lunchbox"), "hint included");
});

await test("buildMessages: invalid inputs -> null", () => {
  eq(buildMessages("scan", {}), null, "scan needs image");
  eq(buildMessages("nl-parse", { text: "   " }), null, "nl-parse needs text");
  eq(buildMessages("coach", { messages: [] }), null, "coach needs messages");
  eq(buildMessages("coach", { messages: [{ role: "system", content: "x" }] }), null, "coach filters non user/assistant");
  eq(buildMessages("insights", {}), null, "insights needs context");
});

await test("buildMessages: coach prepends system + context, keeps history", () => {
  const m = buildMessages("coach", { messages: [{ role: "user", content: "hi" }, { role: "assistant", content: "yo" }], context: { goal: "lose" } });
  eq(m[0].role, "system", "system first");
  ok(m[0].content.includes("goal"), "context embedded");
  eq(m.length, 3, "system + 2 history");
});

await test("buildPayload: output modes", () => {
  const reg = getRegistry({});
  const js = buildPayload(reg.scan, reg.scan.primary, "scan", [{ role: "user", content: "x" }]);
  ok(js.response_format?.json_schema?.strict === true, "json_schema strict");
  ok(Array.isArray(js.plugins) && js.plugins[0].id === "response-healing", "healing plugin");
  ok(js.provider?.require_parameters === true, "require_parameters");
  eq(js.temperature, 0.2, "low temp for extraction");

  const tool = buildPayload({ ...reg["nl-parse"], outputMode: "tool_call" }, "m", "nl-parse", []);
  eq(tool.tool_choice.function.name, "log_nutrition", "forces tool");
  eq(tool.parallel_tool_calls, false, "no parallel tools");

  const coach = buildPayload(reg.coach, reg.coach.primary, "coach", []);
  ok(!coach.response_format && !coach.tools, "text mode = no structured params");
  eq(coach.temperature, 0.5, "warmer for chat");
});

await test("normalizeScanResult: coercion + clamping", () => {
  const n = normalizeScanResult({
    title: "", mealType: "BREAKFAST",
    items: [{ name: "Rice", quantity: "1.5", unit: "", kcal: 205.7, protein: 4.2, carbs: 45, fat: 0.5, fiber: 1, confidence: 1.4 }],
    confidence: -0.2,
  });
  eq(n.title, "Meal", "blank title defaulted");
  eq(n.mealType, "breakfast", "lowercased enum");
  eq(n.items[0].kcal, 206, "kcal rounded");
  eq(n.items[0].unit, "serving", "blank unit defaulted");
  eq(n.items[0].confidence, 1, "item confidence clamped to 1");
  eq(n.confidence, 0, "overall confidence clamped to 0");
  eq(n.totalKcal, 206, "totals summed from items when missing");
});

await test("normalizeScanResult: invalid mealType -> empty (app picks by time)", () => {
  eq(normalizeScanResult({ mealType: "brunch" }).mealType, "", "unknown enum dropped");
  eq(normalizeScanResult({}).items.length, 0, "no items ok");
});

await test("normalizeInsight: filters arrays", () => {
  const n = normalizeInsight({ headline: "Nice day", summary: "good", highlights: ["a", "", 5, "b"], suggestions: "x" });
  eq(n.headline, "Nice day", "headline");
  eq(n.highlights.length, 2, "drops empty/non-string");
  eq(Array.isArray(n.suggestions), true, "suggestions always array");
  eq(n.suggestions.length, 0, "non-array -> []");
});

await test("extractJSON: prose / fenced / nested / strings-with-braces", () => {
  eq(extractJSON('Sure! ```json\n{"a":1}\n```').a, 1, "fenced");
  eq(extractJSON('text {"a":{"b":2}} more').a.b, 2, "nested");
  eq(extractJSON('{"s":"has } brace"}').s, "has } brace", "brace inside string");
  eq(extractJSON("no json here"), null, "none -> null");
});

await test("parseStructured: per mode", () => {
  eq(parseStructured(schemaResp({ x: 1 }).body, "json_schema").x, 1, "json_schema reads content");
  eq(parseStructured(toolResp({ y: 2 }).body, "tool_call").y, 2, "tool_call reads arguments string");
  eq(parseStructured({ choices: [{ message: {} }] }, "tool_call"), null, "missing tool_calls -> null");
  eq(parseStructured(textResp('prefix {"z":3}').body, "prompt_repair").z, 3, "prompt_repair extracts");
});

await test("estimateCostUSD: prefers usage.cost, else token math", () => {
  approx(estimateCostUSD({ cost: 0.42 }, { priceInPerM: 1, priceOutPerM: 1 }), 0.42, "uses reported cost");
  const c = estimateCostUSD({ prompt_tokens: 1_000_000, completion_tokens: 0 }, { priceInPerM: 0.5, priceOutPerM: 2 });
  approx(c, 0.5, "token math fallback");
});

// ===========================================================================
console.log("\n— runTask (mock OpenRouter) —");

await test("scan happy path -> normalized AIScanResult", async () => {
  const fetchImpl = makeFetch(() => schemaResp(VALID_SCAN));
  const out = await runTask(BASE_ENV, { fetchImpl }, "scan", { image_base64: "ABC" });
  eq(out.status, 200, "200");
  eq(out.body.mealType, "breakfast", "normalized enum");
  eq(out.body.items[0].kcal, 141, "rounded kcal");
  eq(fetchImpl.calls.length, 1, "one upstream call");
});

await test("scan low-confidence -> escalation replaces result", async () => {
  const fetchImpl = makeFetch((p) => {
    if (p.model === "google/gemini-3-flash-preview") return schemaResp({ ...VALID_SCAN, title: "Escalated", confidence: 0.95 }, { model: p.model });
    return schemaResp({ ...VALID_SCAN, title: "Primary", confidence: 0.3 }, { model: p.model });
  });
  const out = await runTask(BASE_ENV, { fetchImpl }, "scan", { image_base64: "ABC" });
  eq(out.body.title, "Escalated", "used escalation result");
  eq(out.model, "google/gemini-3-flash-preview", "served by escalation model");
  ok(fetchImpl.calls.length >= 2, "escalation made a second call");
});

await test("scan high-confidence -> no escalation", async () => {
  const fetchImpl = makeFetch((p) => schemaResp({ ...VALID_SCAN, confidence: 0.9 }, { model: p.model }));
  const out = await runTask(BASE_ENV, { fetchImpl }, "scan", { image_base64: "ABC" });
  eq(fetchImpl.calls.length, 1, "no escalation call");
  eq(out.status, 200, "ok");
});

await test("fallback model on retryable error", async () => {
  const fetchImpl = makeFetch((p) => {
    if (p.model === "qwen/qwen3.5-flash-02-23") return errResp(502, "down");
    return schemaResp({ ...VALID_SCAN, confidence: 0.9 }, { model: p.model });
  });
  const out = await runTask(BASE_ENV, { fetchImpl }, "scan", { image_base64: "ABC" });
  eq(out.status, 200, "recovered via fallback");
  eq(out.model, "qwen/qwen3-vl-8b-instruct", "served by fallback");
  eq(fetchImpl.calls.length, 2, "primary + fallback");
});

await test("non-retryable error stops ladder (no fallback attempt)", async () => {
  const fetchImpl = makeFetch(() => errResp(400, "bad params"));
  const out = await runTask(BASE_ENV, { fetchImpl }, "scan", { image_base64: "ABC" });
  eq(out.status, 502, "collapsed to 502 for the app");
  eq(out.body.upstreamStatus, 400, "preserves upstream status");
  eq(fetchImpl.calls.length, 1, "did NOT try fallback on 400");
});

await test("finish_reason length is treated as failure -> fallback", async () => {
  const fetchImpl = makeFetch((p) => {
    if (p.model === "qwen/qwen3.5-flash-02-23") return schemaResp(VALID_SCAN, { finish: "length", model: p.model });
    return schemaResp({ ...VALID_SCAN, confidence: 0.9 }, { model: p.model });
  });
  const out = await runTask(BASE_ENV, { fetchImpl }, "scan", { image_base64: "ABC" });
  eq(out.model, "qwen/qwen3-vl-8b-instruct", "truncation forced fallback");
});

await test("nl-parse -> items", async () => {
  const fetchImpl = makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.8 }));
  const out = await runTask(BASE_ENV, { fetchImpl }, "nl-parse", { text: "2 eggs and toast" });
  eq(out.status, 200, "ok");
  eq(out.body.items.length, 1, "parsed an item");
});

await test("insights -> normalized insight", async () => {
  const fetchImpl = makeFetch(() => schemaResp({ headline: "On track", summary: "Good protein.", highlights: ["High protein"], suggestions: ["Add fiber"] }));
  const out = await runTask(BASE_ENV, { fetchImpl }, "insights", { context: { kcal: 1800 }, scope: "day" });
  eq(out.body.headline, "On track", "headline passed through");
  eq(out.body.suggestions[0], "Add fiber", "suggestion");
});

await test("coach -> reply text", async () => {
  const fetchImpl = makeFetch(() => textResp("Try adding veggies! 🥦"));
  const out = await runTask(BASE_ENV, { fetchImpl }, "coach", { messages: [{ role: "user", content: "tips?" }] });
  eq(out.body.reply, "Try adding veggies! 🥦", "reply");
});

await test("coach empty reply -> fallback then upstream error", async () => {
  const fetchImpl = makeFetch(() => textResp("   "));
  const out = await runTask(BASE_ENV, { fetchImpl }, "coach", { messages: [{ role: "user", content: "?" }] });
  eq(out.status, 502, "empty replies exhaust ladder");
  eq(fetchImpl.calls.length, 2, "tried primary + fallback");
});

await test("unknown task -> 400", async () => {
  const out = await runTask(BASE_ENV, { fetchImpl: makeFetch(() => schemaResp(VALID_SCAN)) }, "teleport", {});
  eq(out.status, 400, "rejected");
});

// ===========================================================================
console.log("\n— handle (HTTP surface) —");

await test("GET -> health 200", async () => {
  const r = await handle(req("/ai", { method: "GET" }), BASE_ENV, { fetchImpl: makeFetch(() => ({})) });
  eq(r.status, 200, "health ok");
});

await test("OPTIONS -> 204 + CORS", async () => {
  const r = await handle(req("/ai", { method: "OPTIONS" }), BASE_ENV, { fetchImpl: makeFetch(() => ({})) });
  eq(r.status, 204, "preflight");
  ok(r.headers.get("access-control-allow-origin") === "*", "CORS header");
});

await test("unknown path -> 404", async () => {
  const r = await handle(req("/nope"), BASE_ENV, { fetchImpl: makeFetch(() => ({})), now: FIXED_NOW });
  eq(r.status, 404, "404");
});

await test("APP_SECRET mismatch -> 401", async () => {
  const env = { ...BASE_ENV, APP_SECRET: "s3cr3t" };
  const r = await handle(req("/ai", { body: { task: "scan", image_base64: "A" } }), env, { fetchImpl: makeFetch(() => schemaResp(VALID_SCAN)), now: FIXED_NOW });
  eq(r.status, 401, "unauthorized");
});

await test("missing OPENROUTER_API_KEY -> 500 not_configured", async () => {
  const r = await handle(req("/ai", { body: { task: "scan", image_base64: "A" } }), {}, { fetchImpl: makeFetch(() => schemaResp(VALID_SCAN)), now: FIXED_NOW });
  eq(r.status, 500, "server not configured");
  eq((await r.json()).code, "not_configured", "typed code");
});

await test("invalid JSON body -> 400", async () => {
  const r = await handle(req("/ai", { body: "{not json" }), BASE_ENV, { fetchImpl: makeFetch(() => schemaResp(VALID_SCAN)), now: FIXED_NOW });
  eq(r.status, 400, "bad json");
});

await test("happy scan over HTTP", async () => {
  const r = await handle(req("/ai", { body: { task: "scan", image_base64: "ABC" } }), BASE_ENV, { fetchImpl: makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.9 })), now: FIXED_NOW });
  eq(r.status, 200, "ok");
  eq((await r.json()).mealType, "breakfast", "normalized result");
});

await test("legacy /analyze path still works", async () => {
  const r = await handle(req("/analyze", { body: { mode: "meal", image_base64: "ABC" } }), BASE_ENV, { fetchImpl: makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.9 })), now: FIXED_NOW });
  eq(r.status, 200, "backward compatible");
});

await test("quota: second call over limit -> 429 + retry-after", async () => {
  const env = { ...BASE_ENV, QUOTAS: JSON.stringify({ scan: { limit: 1, windowSec: 3600 } }) };
  const kv = makeKV();
  const fetchImpl = makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.9 }));
  const headers = { "x-device-id": "dev-1" };
  const r1 = await handle(req("/ai", { body: { task: "scan", image_base64: "A" }, headers }), env, { fetchImpl, kv, now: FIXED_NOW });
  const r2 = await handle(req("/ai", { body: { task: "scan", image_base64: "A" }, headers }), env, { fetchImpl, kv, now: FIXED_NOW });
  eq(r1.status, 200, "first allowed");
  eq(r2.status, 429, "second blocked");
  ok(Number(r2.headers.get("retry-after")) > 0, "retry-after present");
});

await test("spend cap: blocks once recorded spend exceeds cap", async () => {
  const kv = makeKV();
  const fetchImpl = makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.9 }, { cost: 0.5 }));
  // First call: cap disabled, records 0.5 spend for the month.
  await handle(req("/ai", { body: { task: "scan", image_base64: "A" }, headers: { "x-device-id": "d" } }),
    { ...BASE_ENV, MONTHLY_SPEND_CAP_USD: "0" }, { fetchImpl, kv, now: FIXED_NOW });
  // Second call: cap now 0.10 < 0.5 already spent -> blocked.
  const r2 = await handle(req("/ai", { body: { task: "scan", image_base64: "A" }, headers: { "x-device-id": "d" } }),
    { ...BASE_ENV, MONTHLY_SPEND_CAP_USD: "0.10" }, { fetchImpl, kv, now: FIXED_NOW });
  eq(r2.status, 402, "spend cap enforced");
  eq((await r2.json()).code, "spend_cap", "typed code");
});

await test("spend is recorded to KV after success", async () => {
  const kv = makeKV();
  const fetchImpl = makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.9 }, { cost: 0.25 }));
  await handle(req("/ai", { body: { task: "scan", image_base64: "A" }, headers: { "x-device-id": "d" } }),
    { ...BASE_ENV }, { fetchImpl, kv, now: FIXED_NOW });
  const spendKeys = [...kv.store.keys()].filter((k) => k.startsWith("spend:"));
  eq(spendKeys.length, 1, "one month spend key");
  approx(parseFloat(kv.store.get(spendKeys[0])), 0.25, "recorded the cost");
});

await test("no KV bound -> quotas/spend skipped, still works", async () => {
  const r = await handle(req("/ai", { body: { task: "scan", image_base64: "A" } }), BASE_ENV, { fetchImpl: makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.9 })), now: FIXED_NOW });
  eq(r.status, 200, "works without KV");
});

await test("open-proxy guard: blocks unprotected deploy (no secret, no KV, no opt-in)", async () => {
  const r = await handle(req("/ai", { body: { task: "scan", image_base64: "A" } }),
    { OPENROUTER_API_KEY: "k" }, // no APP_SECRET, no ALLOW_OPEN_PROXY, no kv
    { fetchImpl: makeFetch(() => schemaResp(VALID_SCAN)), now: FIXED_NOW });
  eq(r.status, 503, "blocked when unprotected");
  eq((await r.json()).code, "not_configured", "typed code");
});

await test("open-proxy guard: APP_SECRET alone satisfies it", async () => {
  const env = { OPENROUTER_API_KEY: "k", APP_SECRET: "s" };
  const r = await handle(req("/ai", { body: { task: "scan", image_base64: "A" }, headers: { "x-app-secret": "s" } }),
    env, { fetchImpl: makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.9 })), now: FIXED_NOW });
  eq(r.status, 200, "allowed with secret");
});

await test("quota: rotating device-id is still bounded by the IP bucket", async () => {
  const env = { OPENROUTER_API_KEY: "k", QUOTAS: JSON.stringify({ scan: { limit: 1, windowSec: 3600 } }), QUOTA_IP_MULTIPLIER: "2" };
  const kv = makeKV();
  const fetchImpl = makeFetch(() => schemaResp({ ...VALID_SCAN, confidence: 0.9 }));
  const mk = (i) => req("/ai", { body: { task: "scan", image_base64: "A" }, headers: { "x-device-id": "dev-" + i, "cf-connecting-ip": "9.9.9.9" } });
  const r1 = await handle(mk(1), env, { fetchImpl, kv, now: FIXED_NOW });
  const r2 = await handle(mk(2), env, { fetchImpl, kv, now: FIXED_NOW });
  const r3 = await handle(mk(3), env, { fetchImpl, kv, now: FIXED_NOW });
  eq(r1.status, 200, "1st ok");
  eq(r2.status, 200, "2nd ok (within IP limit 2)");
  eq(r3.status, 429, "3rd blocked by IP bucket despite a fresh device id");
});

await test("ipKey extracts cf-connecting-ip", () => {
  eq(ipKey(req("/ai", { headers: { "cf-connecting-ip": "1.2.3.4" } })), "1.2.3.4", "reads edge IP");
  eq(ipKey(req("/ai")), "", "empty when absent");
});

// ===========================================================================
console.log(`\n${passed} passed, ${failed} failed`);
if (failed) { console.error("\nFailures:\n - " + fails.join("\n - ")); process.exit(1); }
console.log("All proxy tests passed ✓");
