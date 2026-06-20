# CalorieBuddy AI Proxy

A tiny serverless function that keeps the Anthropic API key off-device and turns
a meal photo into structured nutrition JSON for the app. The app posts a base64
image to `POST /analyze`; the proxy calls Claude vision with a forced
`log_nutrition` tool and returns its structured input directly (it already
matches the app's `AIScanResult`).

## Endpoint
`POST /analyze`
```json
{ "image_base64": "<jpeg base64>", "mode": "meal" | "label", "hint": "optional" }
```
Response: an `AIScanResult` object (`title`, `mealType`, `items[]`, `totalKcal`,
`totalProtein`, `totalCarbs`, `totalFat`, `totalFiber`, `confidence`, `notes`).

## Deploy (Cloudflare Workers)
1. Install Wrangler: `npm i -g wrangler` and `wrangler login`.
2. From this folder:
   ```sh
   wrangler secret put ANTHROPIC_API_KEY     # paste your Anthropic key
   wrangler secret put APP_SECRET            # optional shared secret
   wrangler deploy
   ```
3. Copy the deployed URL (e.g. `https://caloriebuddy-ai-proxy.<you>.workers.dev`).

## Wire the app
Set `CB_AI_PROXY_URL` (and optional `CB_AI_APP_SECRET`) as Info.plist values —
e.g. via a `Secrets.xcconfig` referenced by the target's build settings, or add
`INFOPLIST_KEY_CB_AI_PROXY_URL` build settings. `AIConfig.default` reads them.
Until set, the app runs the scan flow in **demo mode** with a mock result.

## Model
Defaults to `claude-haiku-4-5-20251001` (cheap, fast vision). For higher
accuracy set `MODEL = "claude-sonnet-4-6"` in `wrangler.toml` or as a var.
Verify current model IDs against the latest Anthropic docs before launch.

## Vercel alternative
The same logic works as a Vercel Edge Function: export a `POST` handler that
reads `ANTHROPIC_API_KEY` from `process.env`, calls the Messages API exactly as
in `worker.js`, and returns the tool input as JSON.

## Notes
- CORS is open (`*`) for convenience; lock it down if you serve a web client.
- Consider rate-limiting per `APP_SECRET` / IP in production.
- Photos are forwarded to Anthropic only to produce the estimate; the proxy
  stores nothing.
