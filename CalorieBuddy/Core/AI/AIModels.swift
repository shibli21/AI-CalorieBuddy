//
//  AIModels.swift
//  CalorieBuddy
//
//  Request/response types for the AI scan. Decoding is defensive: AI output may
//  omit fields or return numbers as decimals, so everything has a fallback.
//

import Foundation

enum ScanMode: String, Codable, Sendable, CaseIterable {
    // Barcode capture is intentionally omitted: a real barcode→nutrition lookup
    // needs a licensed food database, which SPEC §12 lists as a v1 non-goal.
    case meal, label
    var title: String {
        switch self {
        case .meal: "Meal"
        case .label: "Label"
        }
    }
}

// MARK: - Requests (one per task; the proxy dispatches on `task`)

/// Photo scan (meal) or nutrition-label scan.
struct AIScanRequest: Encodable, Sendable {
    var task: String          // "scan" | "label"
    var imageBase64: String
    var hint: String?
    enum CodingKeys: String, CodingKey { case task; case imageBase64 = "image_base64"; case hint }
}

/// Natural-language meal entry: free text -> structured items.
struct AINLParseRequest: Encodable, Sendable {
    let task = "nl-parse"
    var text: String
}

/// AI insights over the user's logged data.
struct AIInsightsRequest: Encodable, Sendable {
    let task = "insights"
    var scope: String         // "day" | "week"
    var context: AIContext
}

/// Conversational coach turn.
struct AICoachRequest: Encodable, Sendable {
    let task = "coach"
    var messages: [AICoachMessage]
    var context: AIContext?
}

/// A single chat turn sent to the proxy (role is "user" or "assistant").
struct AICoachMessage: Encodable, Sendable {
    var role: String
    var content: String
}

/// Snapshot of the user's plan + recent intake, passed as JSON the model reads.
/// All fields optional; the synthesized encoder omits nils.
struct AIContext: Encodable, Sendable {
    var goal: String?
    var dietType: String?
    var calorieTarget: Int?
    var consumed: Int?
    var remaining: Int?
    var protein: Int?
    var carbs: Int?
    var fat: Int?
    var fiber: Int?
    var proteinTarget: Int?
    var nutritionScore: Int?
    var meals: [AIContextMeal]?
    var recentDays: [AIContextDay]?
}

struct AIContextMeal: Encodable, Sendable {
    var name: String
    var mealType: String
    var kcal: Int
}

struct AIContextDay: Encodable, Sendable {
    var date: String
    var kcal: Int
    var score: Int
}

// MARK: - Non-scan responses

/// AI insight payload (insights task). Defensive decoding — fields default empty.
struct AIInsight: Codable, Sendable {
    var headline: String = ""
    var summary: String = ""
    var highlights: [String] = []
    var suggestions: [String] = []

    init(headline: String = "", summary: String = "", highlights: [String] = [], suggestions: [String] = []) {
        self.headline = headline; self.summary = summary
        self.highlights = highlights; self.suggestions = suggestions
    }

    enum CodingKeys: String, CodingKey { case headline, summary, highlights, suggestions }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        headline = (try? c.decode(String.self, forKey: .headline)) ?? ""
        summary = (try? c.decode(String.self, forKey: .summary)) ?? ""
        highlights = (try? c.decode([String].self, forKey: .highlights)) ?? []
        suggestions = (try? c.decode([String].self, forKey: .suggestions)) ?? []
    }

    var isEmpty: Bool { summary.isEmpty && highlights.isEmpty && suggestions.isEmpty }
}

/// Coach reply payload (coach task).
struct AICoachReply: Decodable, Sendable {
    var reply: String
}

/// Typed error body returned by the proxy (`{ error, code }`).
struct AIProxyError: Decodable, Sendable {
    var error: String?
    var code: String?
}

struct AIScanItem: Codable, Identifiable, Sendable, Hashable {
    var id: UUID = UUID()
    var name: String = ""
    var quantity: Double = 1
    var unit: String = "serving"
    var kcal: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fat: Int = 0
    var fiber: Int = 0
    var confidence: Double = 1

    enum CodingKeys: String, CodingKey {
        case name, quantity, unit, kcal, protein, carbs, fat, fiber, confidence
    }

    init(name: String, quantity: Double = 1, unit: String = "serving",
         kcal: Int = 0, protein: Int = 0, carbs: Int = 0, fat: Int = 0,
         fiber: Int = 0, confidence: Double = 1) {
        self.name = name; self.quantity = quantity; self.unit = unit
        self.kcal = kcal; self.protein = protein; self.carbs = carbs
        self.fat = fat; self.fiber = fiber; self.confidence = confidence
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        func flexInt(_ key: CodingKeys, _ def: Int = 0) -> Int {
            if let d = try? c.decode(Double.self, forKey: key) { return Int(d.rounded()) }
            return def
        }
        name = (try? c.decode(String.self, forKey: .name)) ?? ""
        quantity = (try? c.decode(Double.self, forKey: .quantity)) ?? 1
        unit = (try? c.decode(String.self, forKey: .unit)) ?? "serving"
        kcal = flexInt(.kcal)
        protein = flexInt(.protein)
        carbs = flexInt(.carbs)
        fat = flexInt(.fat)
        fiber = flexInt(.fiber)
        confidence = (try? c.decode(Double.self, forKey: .confidence)) ?? 1
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(quantity, forKey: .quantity)
        try c.encode(unit, forKey: .unit)
        try c.encode(kcal, forKey: .kcal)
        try c.encode(protein, forKey: .protein)
        try c.encode(carbs, forKey: .carbs)
        try c.encode(fat, forKey: .fat)
        try c.encode(fiber, forKey: .fiber)
        try c.encode(confidence, forKey: .confidence)
    }
}

struct AIScanResult: Codable, Sendable {
    var title: String = "Meal"
    var mealTypeRaw: String = ""
    var items: [AIScanItem] = []
    var totalKcal: Int = 0
    var totalProtein: Int = 0
    var totalCarbs: Int = 0
    var totalFat: Int = 0
    var totalFiber: Int = 0
    var confidence: Double = 1
    var notes: String = ""

    enum CodingKeys: String, CodingKey {
        case title, items, notes, confidence
        case mealTypeRaw = "mealType"
        case totalKcal, totalProtein, totalCarbs, totalFat, totalFiber
    }

    init(title: String = "Meal", mealTypeRaw: String = "", items: [AIScanItem] = [],
         totalKcal: Int = 0, totalProtein: Int = 0, totalCarbs: Int = 0,
         totalFat: Int = 0, totalFiber: Int = 0, confidence: Double = 1, notes: String = "") {
        self.title = title; self.mealTypeRaw = mealTypeRaw; self.items = items
        self.totalKcal = totalKcal; self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs; self.totalFat = totalFat
        self.totalFiber = totalFiber; self.confidence = confidence; self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        func flexInt(_ key: CodingKeys, _ def: Int = 0) -> Int {
            if let d = try? c.decode(Double.self, forKey: key) { return Int(d.rounded()) }
            return def
        }
        title = (try? c.decode(String.self, forKey: .title)) ?? "Meal"
        mealTypeRaw = (try? c.decode(String.self, forKey: .mealTypeRaw)) ?? ""
        items = (try? c.decode([AIScanItem].self, forKey: .items)) ?? []
        notes = (try? c.decode(String.self, forKey: .notes)) ?? ""
        confidence = (try? c.decode(Double.self, forKey: .confidence)) ?? 1

        // Use provided totals, or sum the items as a fallback.
        let summed = items.reduce(into: (k: 0, p: 0, c: 0, f: 0, fib: 0)) { acc, item in
            acc.k += item.kcal; acc.p += item.protein; acc.c += item.carbs
            acc.f += item.fat; acc.fib += item.fiber
        }
        totalKcal = flexInt(.totalKcal, summed.k)
        totalProtein = flexInt(.totalProtein, summed.p)
        totalCarbs = flexInt(.totalCarbs, summed.c)
        totalFat = flexInt(.totalFat, summed.f)
        totalFiber = flexInt(.totalFiber, summed.fib)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(title, forKey: .title)
        try c.encode(mealTypeRaw, forKey: .mealTypeRaw)
        try c.encode(items, forKey: .items)
        try c.encode(totalKcal, forKey: .totalKcal)
        try c.encode(totalProtein, forKey: .totalProtein)
        try c.encode(totalCarbs, forKey: .totalCarbs)
        try c.encode(totalFat, forKey: .totalFat)
        try c.encode(totalFiber, forKey: .totalFiber)
        try c.encode(confidence, forKey: .confidence)
        try c.encode(notes, forKey: .notes)
    }

    var suggestedMealType: MealType {
        MealType(rawValue: mealTypeRaw) ?? .suggested()
    }

    /// Build a (detached) FoodEntry + Ingredients ready to insert into a context.
    @MainActor
    func makeFoodEntry(mealType: MealType? = nil,
                       source: FoodSource = .aiPhoto,
                       photoData: Data? = nil,
                       at date: Date = .now) -> FoodEntry {
        let entry = FoodEntry(name: title,
                              mealType: mealType ?? suggestedMealType,
                              source: source,
                              loggedAt: date)
        entry.totalKcal = totalKcal
        entry.protein = totalProtein
        entry.carbs = totalCarbs
        entry.fat = totalFat
        entry.fiber = totalFiber
        entry.confidence = confidence
        entry.photoData = photoData
        entry.ingredients = items.map {
            Ingredient(name: $0.name, quantity: $0.quantity, unit: $0.unit,
                       kcal: $0.kcal, protein: $0.protein, carbs: $0.carbs,
                       fat: $0.fat, fiber: $0.fiber)
        }
        return entry
    }
}
