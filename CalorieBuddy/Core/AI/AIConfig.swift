//
//  AIConfig.swift
//  CalorieBuddy
//
//  Configuration for the Claude-vision proxy. The Anthropic API key lives ONLY
//  on the serverless proxy — never in the app. The app talks to the proxy URL.
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

    var analyzeURL: URL? {
        guard isConfigured else { return nil }
        return URL(string: proxyBaseURL)?.appendingPathComponent("analyze")
    }

    static var `default`: AIConfig {
        let url = (Bundle.main.object(forInfoDictionaryKey: "CB_AI_PROXY_URL") as? String ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let secret = Bundle.main.object(forInfoDictionaryKey: "CB_AI_APP_SECRET") as? String
        return AIConfig(proxyBaseURL: url, appSecret: (secret?.isEmpty == false) ? secret : nil)
    }
}
