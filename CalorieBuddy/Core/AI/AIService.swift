//
//  AIService.swift
//  CalorieBuddy
//
//  Sends a meal/label photo to the serverless proxy, which calls Claude vision
//  and returns structured nutrition JSON (AIScanResult).
//

import Foundation
import Observation

enum AIError: LocalizedError {
    case notConfigured
    case badResponse
    case decoding
    case server(Int)
    case network(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "AI scanning isn't set up yet. Add your proxy URL in settings."
        case .badResponse:
            "Got an unexpected response from the server."
        case .decoding:
            "Couldn't read the AI result. Please try again."
        case .server(let code):
            "The server returned an error (\(code)). Please try again."
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

    /// Analyze a meal/label photo and return structured nutrition.
    func analyze(imageData: Data, mode: ScanMode = .meal, hint: String? = nil) async throws -> AIScanResult {
        guard let url = config.analyzeURL else { throw AIError.notConfigured }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let secret = config.appSecret {
            request.setValue(secret, forHTTPHeaderField: "X-App-Secret")
        }
        request.timeoutInterval = 45
        request.httpBody = try JSONEncoder().encode(
            AIRequest(imageBase64: imageData.base64EncodedString(), mode: mode.rawValue, hint: hint)
        )

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIError.network(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else { throw AIError.badResponse }
        guard (200..<300).contains(http.statusCode) else { throw AIError.server(http.statusCode) }

        do {
            return try JSONDecoder().decode(AIScanResult.self, from: data)
        } catch {
            throw AIError.decoding
        }
    }

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
}
