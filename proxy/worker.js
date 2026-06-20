// CalorieBuddy AI proxy — Cloudflare Worker
//
// Holds the Anthropic API key server-side and exposes POST /analyze, which the
// app calls with a base64 image. Returns structured nutrition JSON matching the
// app's AIScanResult.
//
// Env vars (set with `wrangler secret put`):
//   ANTHROPIC_API_KEY  (required)
//   APP_SECRET         (optional shared secret; if set, app must send X-App-Secret)
//   MODEL              (optional, default below)

const DEFAULT_MODEL = "claude-haiku-4-5-20251001"; // bump to claude-sonnet-4-6 for higher accuracy

const NUTRITION_TOOL = {
  name: "log_nutrition",
  description: "Return structured nutrition for the food shown in the image.",
  input_schema: {
    type: "object",
    properties: {
      title: { type: "string", description: "Short name for the whole meal" },
      mealType: { type: "string", enum: ["breakfast", "lunch", "dinner", "snack"] },
      items: {
        type: "array",
        description: "Each distinct food/ingredient detected",
        items: {
          type: "object",
          properties: {
            name: { type: "string" },
            quantity: { type: "number" },
            unit: { type: "string" },
            kcal: { type: "integer" },
            protein: { type: "integer" },
            carbs: { type: "integer" },
            fat: { type: "integer" },
            fiber: { type: "integer" },
            confidence: { type: "number" },
          },
          required: ["name", "kcal", "protein", "carbs", "fat"],
        },
      },
      totalKcal: { type: "integer" },
      totalProtein: { type: "integer" },
      totalCarbs: { type: "integer" },
      totalFat: { type: "integer" },
      totalFiber: { type: "integer" },
      confidence: { type: "number", description: "Overall confidence 0-1" },
      notes: { type: "string" },
    },
    required: ["title", "items", "totalKcal", "confidence"],
  },
};

function cors(extra = {}) {
  return {
    "access-control-allow-origin": "*",
    "access-control-allow-methods": "POST, OPTIONS",
    "access-control-allow-headers": "content-type, x-app-secret",
    ...extra,
  };
}

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: cors({ "content-type": "application/json" }),
  });
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors() });
    if (request.method !== "POST") return json({ error: "method not allowed" }, 405);

    const url = new URL(request.url);
    if (!url.pathname.endsWith("/analyze")) return json({ error: "not found" }, 404);

    if (env.APP_SECRET && request.headers.get("x-app-secret") !== env.APP_SECRET) {
      return json({ error: "unauthorized" }, 401);
    }
    if (!env.ANTHROPIC_API_KEY) return json({ error: "server not configured" }, 500);

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: "invalid json" }, 400);
    }
    const { image_base64, mode = "meal", hint } = body || {};
    if (!image_base64) return json({ error: "missing image_base64" }, 400);

    const system =
      mode === "label"
        ? "You read nutrition labels from photos. Extract per-serving values precisely and return them via the log_nutrition tool. If a value is missing, estimate conservatively."
        : "You are a nutrition estimator. Identify each food in the photo, estimate realistic portion sizes, and return calories and macros via the log_nutrition tool. Prefer common serving sizes. Be honest about uncertainty in the confidence field.";

    const userText = hint ? `Additional context from the user: ${hint}` : "Analyze this food image.";

    const payload = {
      model: env.MODEL || DEFAULT_MODEL,
      max_tokens: 1024,
      system,
      tools: [NUTRITION_TOOL],
      tool_choice: { type: "tool", name: "log_nutrition" },
      messages: [
        {
          role: "user",
          content: [
            { type: "image", source: { type: "base64", media_type: "image/jpeg", data: image_base64 } },
            { type: "text", text: userText },
          ],
        },
      ],
    };

    let resp;
    try {
      resp = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "x-api-key": env.ANTHROPIC_API_KEY,
          "anthropic-version": "2023-06-01",
          "content-type": "application/json",
        },
        body: JSON.stringify(payload),
      });
    } catch (e) {
      return json({ error: "upstream fetch failed", detail: String(e) }, 502);
    }

    if (!resp.ok) {
      const detail = await resp.text();
      return json({ error: "anthropic error", status: resp.status, detail }, 502);
    }

    const data = await resp.json();
    const toolUse = (data.content || []).find((c) => c.type === "tool_use");
    if (!toolUse || !toolUse.input) return json({ error: "no structured output" }, 502);

    // toolUse.input already matches the app's AIScanResult shape.
    return json(toolUse.input, 200);
  },
};
