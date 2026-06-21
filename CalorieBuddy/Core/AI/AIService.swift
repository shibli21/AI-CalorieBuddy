//
//  AIService.swift
//  CalorieBuddy
//
//  The app's single AI client. Talks ONLY to the serverless proxy (one URL),
//  routing every feature by a `task`: scan/label (vision), nl-parse, insights,
//  coach. The proxy holds the OpenRouter key and returns the frozen wire shapes.
//  See docs/adr/ and proxy/.
//

import Foundation
import Observation

enum AIError: LocalizedError {
    case notConfigured
    case unauthorized
    case badResponse
    case decoding
    case server(Int)
    case rateLimited
    case spendCap
    case network(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "AI isn't set up yet. Add your proxy URL in settings."
        case .unauthorized:
            "AI access was rejected. Check the app secret in your proxy settings."
        case .badResponse:
            "Got an unexpected response from the server."
        case .decoding:
            "Couldn't read the AI result. Please try again."
        case .server(let code):
            "The server returned an error (\(code)). Please try again."
        case .rateLimited:
            "You've hit today's AI limit for this feature. Try again later."
        case .spendCap:
            "AI is temporarily unavailable (usage cap reached). Try again later."
        case .network(let message):
            "Network problem: \(message)"
        }
    }
}

@Observable
final class AIService {
    var config: AIConfig

    init(config: AIConfig = .default) {
        self.config = config
    }

    var isConfigured: Bool { config.isConfigured }

    // MARK: - Tasks

    /// Analyze a meal/label photo and return structured nutrition.
    func analyze(imageData: Data, mode: ScanMode = .meal, hint: String? = nil) async throws -> AIScanResult {
        let body = AIScanRequest(task: mode == .label ? "label" : "scan",
                                 imageBase64: imageData.base64EncodedString(),
                                 hint: hint)
        return try await post(body, decoding: AIScanResult.self)
    }

    /// Parse a natural-language meal description ("two eggs and toast") into items.
    func parse(text: String) async throws -> AIScanResult {
        try await post(AINLParseRequest(text: text), decoding: AIScanResult.self)
    }

    /// Generate an insight over the user's logged data.
    func insights(context: AIContext, scope: String = "day") async throws -> AIInsight {
        try await post(AIInsightsRequest(scope: scope, context: context), decoding: AIInsight.self)
    }

    /// Send chat history to the coach and return its reply text.
    func coachReply(messages: [AICoachMessage], context: AIContext? = nil) async throws -> String {
        try await post(AICoachRequest(messages: messages, context: context), decoding: AICoachReply.self).reply
    }

    // MARK: - Transport

    /// A stable per-install id used by the proxy to key per-feature quotas.
    private var deviceID: String {
        let key = "cb.deviceId"
        if let v = UserDefaults.standard.string(forKey: key) { return v }
        let v = UUID().uuidString
        UserDefaults.standard.set(v, forKey: key)
        return v
    }

    private func post<Body: Encodable, Response: Decodable>(_ body: Body, decoding: Response.Type) async throws -> Response {
        guard let url = config.aiURL else { throw AIError.notConfigured }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceID, forHTTPHeaderField: "X-Device-Id")
        if let secret = config.appSecret {
            request.setValue(secret, forHTTPHeaderField: "X-App-Secret")
        }
        request.timeoutInterval = 45
        request.httpBody = try JSONEncoder().encode(body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIError.network(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else { throw AIError.badResponse }
        guard (200..<300).contains(http.statusCode) else { throw mapError(status: http.statusCode, data: data) }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw AIError.decoding
        }
    }

    private func mapError(status: Int, data: Data) -> AIError {
        if let err = try? JSONDecoder().decode(AIProxyError.self, from: data) {
            switch err.code {
            case "rate_limited": return .rateLimited
            case "spend_cap": return .spendCap
            case "not_configured": return .notConfigured
            case "unauthorized": return .unauthorized
            default: break
            }
        }
        if status == 429 { return .rateLimited }
        if status == 402 { return .spendCap }
        if status == 401 { return .unauthorized }
        return .server(status)
    }

    // MARK: - Demo fallbacks (used when no proxy is configured; DEBUG only)

    /// Deterministic sample result for previews and offline demos.
    static func mockResult() -> AIScanResult {
        AIScanResult(
            title: "Avocado toast & egg",
            mealTypeRaw: MealType.breakfast.rawValue,
            items: [
                AIScanItem(name: "Sourdough toast", quantity: 1, unit: "slice", kcal: 120, protein: 4, carbs: 22, fat: 2, fiber: 2, confidence: 0.94),
                AIScanItem(name: "Avocado", quantity: 0.5, unit: "fruit", kcal: 160, protein: 2, carbs: 9, fat: 15, fiber: 7, confidence: 0.9),
                AIScanItem(name: "Poached egg", quantity: 1, unit: "egg", kcal: 78, protein: 6, carbs: 1, fat: 5, fiber: 0, confidence: 0.96),
            ],
            confidence: 0.93,
            notes: "Estimated from a single photo."
        )
    }

    /// A plausible parse for the demo NL-entry flow, seeded from the typed text.
    static func mockParse(text: String) -> AIScanResult {
        let name = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return AIScanResult(
            title: name.isEmpty ? "Meal" : name.prefix(1).uppercased() + name.dropFirst(),
            mealTypeRaw: MealType.suggested().rawValue,
            items: [
                AIScanItem(name: name.isEmpty ? "Food" : name, quantity: 1, unit: "serving",
                           kcal: 250, protein: 12, carbs: 30, fat: 9, fiber: 3, confidence: 0.7),
            ],
            confidence: 0.7,
            notes: "Demo estimate — connect the AI proxy for real results."
        )
    }

    static func mockInsight() -> AIInsight {
        AIInsight(
            headline: "Strong protein day",
            summary: "You're tracking well against your goal and your protein is on point. A bit more fiber would round things out.",
            highlights: ["Protein target nearly met", "Calories within budget"],
            suggestions: ["Add a piece of fruit or some veggies for fiber", "Keep meals spaced through the day"]
        )
    }

    static func mockCoachReply(to message: String) -> String {
        "That's a great question! (Demo mode — connect the AI proxy in Settings to chat for real.) "
        + "In general, aim for balanced meals with protein, fiber, and plenty of water."
    }
}
