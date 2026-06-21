// CalorieBuddy AI proxy — Cloudflare Worker (OpenRouter edition)
//
// Holds the single OPENROUTER_API_KEY server-side and exposes one endpoint,
// POST /ai, that the app calls with a `task`. The proxy owns a data-driven model
// registry (task -> model), forces structured output per model, normalizes the
// result to the app's frozen wire schema, escalates low-confidence scans, and
// enforces per-task quotas + a monthly spend cap.
//
// See docs/adr/0001..0006 and UBIQUITOUS_LANGUAGE.md for the design.
//
// Env (wrangler secret put / [vars]):
//   OPENROUTER_API_KEY   (required)
//   APP_SECRET           (optional shared secret; app sends X-App-Secret)
//   MODEL_REGISTRY       (optional JSON overriding DEFAULT_REGISTRY, partial ok)
//   MODEL_<TASK>         (optional single-slug override, e.g. MODEL_SCAN)
//   CONFIDENCE_THRESHOLD (optional, default 0.6)
//   MONTHLY_SPEND_CAP_USD(optional, default 0 = disabled)
//   QUOTAS               (optional JSON overriding DEFAULT_QUOTAS)
//   OPENROUTER_REFERER   (optional, sent as HTTP-Referer)
// Bindings:
//   RATE_KV              (optional KV namespace; without it, quotas/spend are skipped)
//
// Backward note: the legacy POST /analyze body ({image_base64, mode}) still works
// and is treated as task "scan"/"label".

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";
const DEFAULT_CONFIDENCE_THRESHOLD = 0.6;

// --- Model registry (data, not code — slugs are tuned via env; verify on OpenRouter) ---
// outputMode: "json_schema" | "tool_call" | "prompt_repair" | "text"
// Slugs verified on OpenRouter 2026-06-21. Pin DATED qwen slug — bare
// `qwen/qwen3.5-flash` 404s on the per-endpoint API. To prefer Kimi K2 for text
// tasks (the user's original ask), set e.g. MODEL_NL_PARSE=moonshotai/kimi-k2.5.
const DEFAULT_REGISTRY = {
  scan:              { primary: "qwen/qwen3.5-flash-02-23",             fallback: "qwen/qwen3-vl-8b-instruct",             vision: true,  outputMode: "json_schema", maxTokens: 1200, priceInPerM: 0.065, priceOutPerM: 0.26 },
  "scan-escalation": { primary: "google/gemini-3-flash-preview",        fallback: "google/gemini-3.1-flash-lite-preview",  vision: true,  outputMode: "json_schema", maxTokens: 1200, priceInPerM: 0.50,  priceOutPerM: 3.00 },
  label:             { primary: "qwen/qwen3.5-flash-02-23",             fallback: "qwen/qwen3-vl-8b-instruct",             vision: true,  outputMode: "json_schema", maxTokens: 1200, priceInPerM: 0.065, priceOutPerM: 0.26 },
  "nl-parse":        { primary: "qwen/qwen3.5-flash-02-23",             fallback: "google/gemini-3.1-flash-lite-preview",  vision: false, outputMode: "json_schema", maxTokens: 700,  priceInPerM: 0.065, priceOutPerM: 0.26 },
  insights:          { primary: "qwen/qwen3.5-flash-02-23",             fallback: "google/gemini-3.1-flash-lite-preview",  vision: false, outputMode: "json_schema", maxTokens: 768,  priceInPerM: 0.065, priceOutPerM: 0.26 },
  coach:             { primary: "google/gemini-3.1-flash-lite-preview", fallback: "qwen/qwen3.5-flash-02-23",              vision: false, outputMode: "text",        maxTokens: 700,  priceInPerM: 0.25,  priceOutPerM: 1.50 },
};

// Anti-abuse ceilings, per caller per task. NOT the product's free-tier limit
// (that's the client-side ScanQuota, UX only). windowSec defines the bucket.
const DEFAULT_QUOTAS = {
  scan:       { limit: 60, windowSec: 86400 },
  label:      { limit: 60, windowSec: 86400 },
  "nl-parse": { limit: 60, windowSec: 86400 },
  insights:   { limit: 40, windowSec: 86400 },
  coach:      { limit: 60, windowSec: 3600 },
};

// --- JSON schema shared by scan / label / nl-parse (matches the app's AIScanResult) ---
// Strict-mode friendly: additionalProperties:false and every property required.
const NUTRITION_ITEM = {
  type: "object",
  additionalProperties: false,
  properties: {
    name: { type: "string" },
    quantity: { type: "number" },
    unit: { type: "string" },
    kcal: { type: "integer" },
    protein: { type: "integer" },
    carbs: { type: "integer" },
    fat: { type: "integer" },
    fiber: { type: "integer" },
    confidence: { type: "number", description: "0-1 certainty for this item" },
  },
  required: ["name", "quantity", "unit", "kcal", "protein", "carbs", "fat", "fiber", "confidence"],
};

const NUTRITION_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    title: { type: "string", description: "Short name for the whole meal" },
    mealType: { type: "string", enum: ["breakfast", "lunch", "dinner", "snack"] },
    items: { type: "array", items: NUTRITION_ITEM },
    totalKcal: { type: "integer" },
    totalProtein: { type: "integer" },
    totalCarbs: { type: "integer" },
    totalFat: { type: "integer" },
    totalFiber: { type: "integer" },
    confidence: { type: "number", description: "Overall confidence 0-1" },
    notes: { type: "string" },
  },
  required: ["title", "mealType", "items", "totalKcal", "totalProtein", "totalCarbs", "totalFat", "totalFiber", "confidence", "notes"],
};

const INSIGHT_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    headline: { type: "string", description: "<=6 word upbeat headline" },
    summary: { type: "string", description: "2-3 sentence plain-language summary" },
    highlights: { type: "array", items: { type: "string" }, description: "short factual bullet points" },
    suggestions: { type: "array", items: { type: "string" }, description: "1-3 gentle, actionable tips" },
  },
  required: ["headline", "summary", "highlights", "suggestions"],
};

function schemaForTask(task) {
  if (task === "insights") return { name: "insight", schema: INSIGHT_SCHEMA, toolName: "report_insight" };
  if (task === "scan" || task === "label" || task === "nl-parse") {
    return { name: "nutrition", schema: NUTRITION_SCHEMA, toolName: "log_nutrition" };
  }
  return null; // coach -> free text
}

// --- System prompts ---
const SYSTEM = {
  scan: "You are a nutrition estimator. Identify each food in the photo, estimate realistic portion sizes, and return calories and macros. Prefer common serving sizes. Be honest about uncertainty in the confidence fields.",
  label: "You read nutrition labels from photos. Extract per-serving values precisely. If a value is missing, estimate conservatively and lower the confidence.",
  "nl-parse": "You convert a written meal description into structured nutrition. Identify each distinct food, estimate realistic portions when unstated, and return calories and macros. Be honest about uncertainty in the confidence fields.",
  insights: "You are CalorieBuddy's supportive nutrition coach. Given a user's logged nutrition data, write a brief, encouraging, specific insight. Be concrete about what went well and one thing to improve. Never give medical advice or diagnose.",
  coach: "You are CalorieBuddy, a friendly, concise nutrition coach. Use the user's context (goals, today's intake) when relevant. Keep replies short and supportive. You are not a medical professional: if asked about medical, clinical, eating-disorder, or medication topics, gently add that they should consult a qualified professional.",
};

// ---------------------------------------------------------------------------
// Pure helpers (exported for the test harness)
// ---------------------------------------------------------------------------

export function getRegistry(env = {}) {
  let reg = { ...DEFAULT_REGISTRY };
  if (env.MODEL_REGISTRY) {
    try {
      const override = JSON.parse(env.MODEL_REGISTRY);
      for (const k of Object.keys(override)) reg[k] = { ...reg[k], ...override[k] };
    } catch { /* ignore malformed override; keep defaults */ }
  }
  // Single-slug overrides: MODEL_SCAN, MODEL_NL_PARSE, MODEL_COACH, ...
  for (const task of Object.keys(reg)) {
    const key = "MODEL_" + task.toUpperCase().replace(/-/g, "_");
    if (env[key]) reg[task] = { ...reg[task], primary: env[key] };
  }
  return reg;
}

export function getQuotas(env = {}) {
  let q = { ...DEFAULT_QUOTAS };
  if (env.QUOTAS) {
    try {
      const o = JSON.parse(env.QUOTAS);
      for (const k of Object.keys(o)) q[k] = { ...q[k], ...o[k] };
    } catch { /* ignore */ }
  }
  return q;
}

export function inferTask(body = {}) {
  if (body.task) return String(body.task);
  if (body.mode === "label") return "label";
  if (body.image_base64) return "scan";
  if (body.text) return "nl-parse";
  return "scan";
}

export function buildMessages(task, body = {}) {
  const system = SYSTEM[task];
  if (!system && task !== "coach") return null;

  if (task === "scan" || task === "label") {
    if (!body.image_base64) return null;
    const userText = body.hint ? `Additional context from the user: ${body.hint}` : "Analyze this food image.";
    return [
      { role: "system", content: system },
      {
        role: "user",
        content: [
          { type: "text", text: userText },
          { type: "image_url", image_url: { url: `data:image/jpeg;base64,${body.image_base64}` } },
        ],
      },
    ];
  }
  if (task === "nl-parse") {
    if (!body.text || !String(body.text).trim()) return null;
    return [
      { role: "system", content: system },
      { role: "user", content: `Meal description: ${body.text}` },
    ];
  }
  if (task === "insights") {
    if (!body.context) return null;
    const scope = body.scope || "day";
    return [
      { role: "system", content: system },
      { role: "user", content: `Scope: ${scope}\nLogged data (JSON):\n${JSON.stringify(body.context)}` },
    ];
  }
  if (task === "coach") {
    const history = Array.isArray(body.messages) ? body.messages : null;
    if (!history || history.length === 0) return null;
    const clean = history
      .filter((m) => m && (m.role === "user" || m.role === "assistant") && typeof m.content === "string")
      .map((m) => ({ role: m.role, content: m.content }));
    if (clean.length === 0) return null;
    const sys = body.context
      ? `${SYSTEM.coach}\n\nUser context (JSON): ${JSON.stringify(body.context)}`
      : SYSTEM.coach;
    return [{ role: "system", content: sys }, ...clean];
  }
  return null;
}

export function buildPayload(entry, model, task, messages) {
  const payload = {
    model,
    messages,
    max_tokens: entry.maxTokens || 1024,
    temperature: task === "coach" ? 0.5 : 0.2, // low for extraction; warmer for chat
    usage: { include: true }, // ask OpenRouter to report cost; we fall back to token math if absent
  };
  const s = schemaForTask(task);
  if (entry.outputMode === "json_schema" && s) {
    payload.response_format = { type: "json_schema", json_schema: { name: s.name, strict: true, schema: s.schema } };
    payload.plugins = [{ id: "response-healing" }]; // repair minor JSON drift (non-streaming only)
    payload.provider = { require_parameters: true }; // exclude routes that can't honor response_format
  } else if (entry.outputMode === "tool_call" && s) {
    payload.tools = [{ type: "function", function: { name: s.toolName, description: "Return the structured result.", parameters: s.schema } }];
    payload.tool_choice = { type: "function", function: { name: s.toolName } };
    payload.parallel_tool_calls = false;
    payload.provider = { require_parameters: true };
  }
  // "text" and "prompt_repair" add nothing here (prompt_repair relies on the prompt + extraction)
  return payload;
}

function safeParse(str) {
  if (typeof str !== "string") return (str && typeof str === "object") ? str : null;
  try { return JSON.parse(str); } catch { return null; }
}

// Extract the first balanced JSON object from free text (prompt_repair / last resort).
export function extractJSON(text) {
  if (typeof text !== "string") return null;
  const start = text.indexOf("{");
  if (start < 0) return null;
  let depth = 0, inStr = false, esc = false;
  for (let i = start; i < text.length; i++) {
    const c = text[i];
    if (inStr) {
      if (esc) esc = false;
      else if (c === "\\") esc = true;
      else if (c === '"') inStr = false;
    } else if (c === '"') inStr = true;
    else if (c === "{") depth++;
    else if (c === "}") { depth--; if (depth === 0) return safeParse(text.slice(start, i + 1)); }
  }
  return null;
}

export function messageText(data) {
  return data?.choices?.[0]?.message?.content ?? "";
}

export function parseStructured(data, outputMode) {
  const msg = data?.choices?.[0]?.message;
  if (!msg) return null;
  if (outputMode === "tool_call") {
    const args = msg.tool_calls?.[0]?.function?.arguments;
    return safeParse(args) ?? extractJSON(typeof msg.content === "string" ? msg.content : "");
  }
  if (outputMode === "json_schema") {
    return safeParse(msg.content) ?? extractJSON(typeof msg.content === "string" ? msg.content : "");
  }
  // prompt_repair / fallback
  return extractJSON(typeof msg.content === "string" ? msg.content : "");
}

function toInt(v, def = 0) {
  const n = typeof v === "number" ? v : parseFloat(v);
  return Number.isFinite(n) ? Math.round(n) : def;
}
function toNum(v, def = 0) {
  const n = typeof v === "number" ? v : parseFloat(v);
  return Number.isFinite(n) ? n : def;
}
function clamp01(v) { return Math.max(0, Math.min(1, toNum(v, 1))); }

const MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"];

// Coerce any model output into the app's frozen AIScanResult shape.
export function normalizeScanResult(obj) {
  const o = obj && typeof obj === "object" ? obj : {};
  const rawItems = Array.isArray(o.items) ? o.items : [];
  const items = rawItems.map((it) => {
    const x = it && typeof it === "object" ? it : {};
    return {
      name: typeof x.name === "string" ? x.name : "",
      quantity: toNum(x.quantity, 1),
      unit: typeof x.unit === "string" && x.unit ? x.unit : "serving",
      kcal: toInt(x.kcal),
      protein: toInt(x.protein),
      carbs: toInt(x.carbs),
      fat: toInt(x.fat),
      fiber: toInt(x.fiber),
      confidence: clamp01(x.confidence),
    };
  });
  const sum = items.reduce(
    (a, it) => ({ k: a.k + it.kcal, p: a.p + it.protein, c: a.c + it.carbs, f: a.f + it.fat, fib: a.fib + it.fiber }),
    { k: 0, p: 0, c: 0, f: 0, fib: 0 }
  );
  let mealType = typeof o.mealType === "string" ? o.mealType.toLowerCase().trim() : "";
  if (!MEAL_TYPES.includes(mealType)) mealType = "";
  return {
    title: typeof o.title === "string" && o.title ? o.title : "Meal",
    mealType,
    items,
    totalKcal: o.totalKcal != null ? toInt(o.totalKcal, sum.k) : sum.k,
    totalProtein: o.totalProtein != null ? toInt(o.totalProtein, sum.p) : sum.p,
    totalCarbs: o.totalCarbs != null ? toInt(o.totalCarbs, sum.c) : sum.c,
    totalFat: o.totalFat != null ? toInt(o.totalFat, sum.f) : sum.f,
    totalFiber: o.totalFiber != null ? toInt(o.totalFiber, sum.fib) : sum.fib,
    confidence: clamp01(o.confidence),
    notes: typeof o.notes === "string" ? o.notes : "",
  };
}

export function normalizeInsight(obj) {
  const o = obj && typeof obj === "object" ? obj : {};
  const arr = (v) => (Array.isArray(v) ? v.filter((s) => typeof s === "string" && s.trim()).slice(0, 6) : []);
  return {
    headline: typeof o.headline === "string" ? o.headline : "",
    summary: typeof o.summary === "string" ? o.summary : "",
    highlights: arr(o.highlights),
    suggestions: arr(o.suggestions),
  };
}

export function estimateCostUSD(usage, entry) {
  if (!usage) return 0;
  if (typeof usage.cost === "number" && usage.cost > 0) return usage.cost;
  const pin = entry?.priceInPerM || 0;
  const pout = entry?.priceOutPerM || 0;
  const inTok = toInt(usage.prompt_tokens, 0);
  const outTok = toInt(usage.completion_tokens, 0);
  return (inTok / 1e6) * pin + (outTok / 1e6) * pout;
}

// ---------------------------------------------------------------------------
// HTTP plumbing
// ---------------------------------------------------------------------------

function cors(extra = {}) {
  return {
    "access-control-allow-origin": "*",
    "access-control-allow-methods": "POST, OPTIONS",
    "access-control-allow-headers": "content-type, x-app-secret, x-device-id",
    ...extra,
  };
}
function json(obj, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(obj), { status, headers: cors({ "content-type": "application/json", ...extraHeaders }) });
}

export function callerKey(request, body = {}) {
  const dev = request?.headers?.get?.("x-device-id") || body.device_id;
  const ip = request?.headers?.get?.("cf-connecting-ip") || request?.headers?.get?.("x-forwarded-for");
  const raw = String(dev || ip || "anon").slice(0, 80);
  return raw.replace(/[^A-Za-z0-9_.:-]/g, "_");
}

/// The edge-set client IP, used as a quota bucket a client cannot rotate (unlike
/// the device id). Empty when not behind Cloudflare (e.g. local tests).
export function ipKey(request) {
  const ip = request?.headers?.get?.("cf-connecting-ip") || request?.headers?.get?.("x-forwarded-for") || "";
  return String(ip).slice(0, 80).replace(/[^A-Za-z0-9_.:-]/g, "_");
}

// ---------------------------------------------------------------------------
// OpenRouter call + fallback
// ---------------------------------------------------------------------------

async function callOpenRouter(env, fetchImpl, payload) {
  let resp;
  try {
    resp = await fetchImpl(OPENROUTER_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.OPENROUTER_API_KEY}`,
        "Content-Type": "application/json",
        "HTTP-Referer": env.OPENROUTER_REFERER || "https://caloriebuddy.app",
        "X-Title": "CalorieBuddy",
      },
      body: JSON.stringify(payload),
    });
  } catch (e) {
    return { ok: false, status: 502, detail: `upstream fetch failed: ${String(e)}` };
  }
  const text = await resp.text();
  let data;
  try { data = JSON.parse(text); } catch { return { ok: false, status: 502, detail: `non-JSON upstream: ${text.slice(0, 200)}` }; }
  if (!resp.ok) {
    const detail = data?.error?.message || text.slice(0, 300);
    return { ok: false, status: resp.status, detail };
  }
  if (data?.error) return { ok: false, status: 502, detail: data.error.message || "upstream error" };
  return { ok: true, data };
}

// HTTP statuses that mean "don't bother trying another model" (params/auth/credits/policy).
const NON_RETRYABLE = new Set([400, 401, 402, 403]);

// Attempt ONE model end-to-end: call + validate finish_reason + parse/extract.
// Returns { ok:true, parsed?|reply?, usage, model } or { ok:false, status, detail, retryable, usage? }.
async function attemptModel(env, deps, entry, model, task) {
  const payload = buildPayload(entry, model, task, deps._messages);
  const r = await callOpenRouter(env, deps.fetchImpl, payload);
  if (!r.ok) return { ok: false, status: r.status, detail: `${model}: ${r.detail}`, retryable: !NON_RETRYABLE.has(r.status) };

  const choice = r.data?.choices?.[0];
  const finish = choice?.finish_reason;
  const usage = r.data?.usage;
  const served = r.data?.model || model;
  // Truncation/error finishes are unusable; Response Healing can't fix truncation.
  if (finish === "length") return { ok: false, status: 502, detail: `truncated (finish_reason=length) on ${served}`, retryable: true, usage };
  if (finish === "error") return { ok: false, status: 502, detail: `model error finish on ${served}`, retryable: true, usage };

  if (task === "coach") {
    const reply = messageText(r.data).trim();
    if (!reply) return { ok: false, status: 502, detail: `empty reply on ${served}`, retryable: true, usage };
    return { ok: true, reply, usage, model: served };
  }
  const parsed = parseStructured(r.data, entry.outputMode);
  if (!parsed) return { ok: false, status: 502, detail: `no structured output on ${served}`, retryable: true, usage };
  return { ok: true, parsed, usage, model: served };
}

// Run the retry ladder for one registry entry: primary, then fallback. Stops
// early on a non-retryable status. Returns the first usable attempt, else the last failure.
async function runLadder(env, deps, entry, task) {
  const models = [entry.primary, entry.fallback].filter(Boolean);
  let last = { ok: false, status: 502, detail: "no model configured", retryable: false };
  for (const model of models) {
    const a = await attemptModel(env, deps, entry, model, task);
    if (a.ok) return a;
    last = a;
    if (!a.retryable) break;
  }
  return last;
}

// ---------------------------------------------------------------------------
// Quota + spend (KV-backed; skipped when no KV is bound)
// ---------------------------------------------------------------------------

function monthKey(now) {
  const d = new Date(now);
  return `spend:${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, "0")}`;
}

// Enforce every bucket (device + IP). The device id is client-controlled and can
// be rotated to dodge its bucket, so a looser IP bucket (scale > 1) is the real
// ceiling. Soft limit: KV is eventually consistent with no atomic increment.
async function checkAndConsumeQuota(kv, quotas, task, buckets, now) {
  if (!kv) return { ok: true };
  const q = quotas[task];
  if (!q) return { ok: true };
  const windowSec = q.windowSec;
  const idx = Math.floor(now / 1000 / windowSec);

  for (const b of buckets) {
    const limit = Math.max(1, Math.round(q.limit * (b.scale ?? 1)));
    const key = `q:${task}:${b.tag}:${b.id}:${idx}`;
    let count;
    try { count = parseInt((await kv.get(key)) || "0", 10) || 0; } catch { return { ok: true }; } // fail-open on read error
    if (count >= limit) {
      const retry = (idx + 1) * windowSec - Math.floor(now / 1000);
      return { ok: false, retryAfter: Math.max(1, retry) };
    }
  }
  for (const b of buckets) {
    const key = `q:${task}:${b.tag}:${b.id}:${idx}`;
    try {
      const count = parseInt((await kv.get(key)) || "0", 10) || 0;
      await kv.put(key, String(count + 1), { expirationTtl: windowSec + 60 });
    } catch { /* best effort */ }
  }
  return { ok: true };
}

async function spendCapExceeded(kv, env, now) {
  const cap = Number(env.MONTHLY_SPEND_CAP_USD || 0);
  if (!kv || !cap) return false;
  try {
    const spent = parseFloat((await kv.get(monthKey(now))) || "0") || 0;
    return spent >= cap; // fail-closed only when we can read a value over the cap
  } catch { return false; } // fail-open on read error so a KV blip doesn't kill the app
}

async function recordSpend(kv, now, usd) {
  if (!kv || !usd) return;
  try {
    const key = monthKey(now);
    const cur = parseFloat((await kv.get(key)) || "0") || 0;
    await kv.put(key, String(cur + usd), { expirationTtl: 70 * 86400 });
  } catch { /* best effort */ }
}

// ---------------------------------------------------------------------------
// Core task runner
// ---------------------------------------------------------------------------

export async function runTask(env, deps, task, body) {
  const registry = getRegistry(env);
  const entry = registry[task];
  if (!entry) return { status: 400, body: { error: `unknown task: ${task}`, code: "bad_request" } };

  const messages = buildMessages(task, body);
  if (!messages) return { status: 400, body: { error: `missing or invalid input for task '${task}'`, code: "bad_request" } };

  const deps2 = { ...deps, _messages: messages };
  const res = await runLadder(env, deps2, entry, task);
  if (!res.ok) {
    // Collapse all upstream provider failures to 502 so the proxy's own status
    // codes (401 secret, 402 spend cap, 429 quota, 500 not-configured) stay unambiguous.
    return { status: 502, body: { error: "AI provider error", code: "upstream", detail: res.detail, upstreamStatus: res.status } };
  }

  let cost = estimateCostUSD(res.usage, entry);

  if (task === "coach") return { status: 200, body: { reply: res.reply }, cost, model: res.model };
  if (task === "insights") return { status: 200, body: normalizeInsight(res.parsed), cost, model: res.model };

  // scan / label / nl-parse -> AIScanResult
  let scan = normalizeScanResult(res.parsed);
  let model = res.model;

  // Confidence escalation for vision scans only — bounded: fires once, sub-threshold only.
  const threshold = Number(env.CONFIDENCE_THRESHOLD ?? DEFAULT_CONFIDENCE_THRESHOLD);
  if ((task === "scan" || task === "label") && scan.confidence < threshold) {
    const escEntry = registry["scan-escalation"];
    if (escEntry && escEntry.primary && escEntry.primary !== entry.primary) {
      const esc = await runLadder(env, deps2, escEntry, task);
      if (esc.ok && esc.parsed) {
        scan = normalizeScanResult(esc.parsed);
        cost += estimateCostUSD(esc.usage, escEntry);
        model = esc.model;
      }
    }
  }

  return { status: 200, body: scan, cost, model };
}

// ---------------------------------------------------------------------------
// Request handler (injectable deps for testing)
// ---------------------------------------------------------------------------

export async function handle(request, env, deps = {}) {
  const fetchImpl = deps.fetchImpl || fetch;
  const kv = deps.kv || env.RATE_KV || null;
  const now = deps.now ? deps.now() : Date.now();

  if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors() });
  if (request.method === "GET") return json({ ok: true, service: "caloriebuddy-ai-proxy" }, 200);
  if (request.method !== "POST") return json({ error: "method not allowed", code: "bad_request" }, 405);

  const path = new URL(request.url).pathname;
  if (!(path.endsWith("/ai") || path.endsWith("/analyze"))) return json({ error: "not found", code: "bad_request" }, 404);

  if (env.APP_SECRET && request.headers.get("x-app-secret") !== env.APP_SECRET) {
    return json({ error: "unauthorized", code: "unauthorized" }, 401);
  }
  if (!env.OPENROUTER_API_KEY) return json({ error: "server not configured", code: "not_configured" }, 500);

  // Safe-by-default: refuse to run as an open, unlimited proxy in front of a paid
  // key. Require an app secret OR a KV-backed quota; override only with an explicit
  // opt-in (e.g. a throwaway local smoke test).
  if (!env.APP_SECRET && !kv && env.ALLOW_OPEN_PROXY !== "true") {
    return json({ error: "proxy is unprotected: set APP_SECRET or bind RATE_KV (or ALLOW_OPEN_PROXY=true to override)", code: "not_configured" }, 503);
  }

  let body;
  try { body = await request.json(); } catch { return json({ error: "invalid json", code: "bad_request" }, 400); }

  const task = inferTask(body);

  if (await spendCapExceeded(kv, env, now)) {
    return json({ error: "monthly spend cap reached; try later", code: "spend_cap" }, 402);
  }

  // Two quota buckets: the (rotatable) device id at the task limit, and the
  // edge-set IP at a looser multiple that device-id rotation can't escape.
  const ipMultiplier = Number(env.QUOTA_IP_MULTIPLIER || 8);
  const ip = ipKey(request);
  const buckets = [{ tag: "dev", id: callerKey(request, body), scale: 1 }];
  if (ip) buckets.push({ tag: "ip", id: ip, scale: ipMultiplier });

  const quotas = getQuotas(env);
  const quota = await checkAndConsumeQuota(kv, quotas, task, buckets, now);
  if (!quota.ok) {
    return json({ error: "rate limit reached for this feature", code: "rate_limited" }, 429, { "retry-after": String(quota.retryAfter) });
  }

  const out = await runTask(env, { fetchImpl }, task, body);

  if (out.status === 200 && out.cost) {
    // record spend (best-effort; don't block the response)
    if (deps.waitUntil) deps.waitUntil(recordSpend(kv, now, out.cost));
    else await recordSpend(kv, now, out.cost);
  }

  return json(out.body, out.status);
}

export default {
  async fetch(request, env, ctx) {
    return handle(request, env, { waitUntil: ctx ? ctx.waitUntil.bind(ctx) : null });
  },
};
