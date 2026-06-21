//
//  AIConfig.swift
//  CalorieBuddy
//
//  Configuration for the serverless AI proxy (OpenRouter). The provider API key
//  lives ONLY on the proxy — never in the app. The app talks to one proxy URL and
//  routes every AI feature by a `task` field (see docs/adr/0001-0002, proxy/).
//
//  Set CB_AI_PROXY_URL (and optional CB_AI_APP_SECRET) as Info.plist values,
//  typically via an .xcconfig / build setting. See docs/SETUP.md and proxy/.
//

import Foundation

struct AIConfig: Sendable {
    var proxyBaseURL: String
    var appSecret: String?

    var isConfigured: Bool {
        !proxyBaseURL.isEmpty && URL(string: proxyBaseURL) != nil
    }

    /// Single task-dispatching endpoint. The proxy also accepts the legacy
    /// `/analyze` path, but the app uses `/ai` for all tasks.
    var aiURL: URL? {
        guard isConfigured else { return nil }
        return URL(string: proxyBaseURL)?.appendingPathComponent("ai")
    }

    static var `default`: AIConfig {
        let url = (Bundle.main.object(forInfoDictionaryKey: "CB_AI_PROXY_URL") as? String ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let secret = Bundle.main.object(forInfoDictionaryKey: "CB_AI_APP_SECRET") as? String
        return AIConfig(proxyBaseURL: url, appSecret: (secret?.isEmpty == false) ? secret : nil)
    }
}
