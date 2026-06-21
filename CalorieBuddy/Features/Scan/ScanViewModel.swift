//
//  ScanViewModel.swift
//  CalorieBuddy
//
//  Drives the scan flow: analyze a photo, hold the editable result, and save.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class ScanViewModel {
    enum Phase { case capture, analyzing, review, error }

    var phase: Phase = .capture
    var mode: ScanMode = .meal
    var image: UIImage?
    var errorMessage: String?

    // Editable result
    var title: String = ""
    var mealType: MealType = .suggested()
    var loggedAt: Date = .now
    var items: [AIScanItem] = []
    var confidence: Double = 1

    var totalKcal: Int { items.reduce(0) { $0 + $1.kcal } }
    var totalProtein: Int { items.reduce(0) { $0 + $1.protein } }
    var totalCarbs: Int { items.reduce(0) { $0 + $1.carbs } }
    var totalFat: Int { items.reduce(0) { $0 + $1.fat } }
    var totalFiber: Int { items.reduce(0) { $0 + $1.fiber } }
    var isLowConfidence: Bool { confidence < 0.6 }

    @MainActor
    func analyze(image: UIImage, ai: AIService) async {
        self.image = image
        phase = .analyzing
        errorMessage = nil

        let result: AIScanResult
        do {
            if ai.isConfigured, let data = image.jpegForUpload() {
                result = try await ai.analyze(imageData: data, mode: mode)
            } else {
                #if DEBUG
                // No proxy configured yet — use a sample result so the flow is
                // testable in development. Never ship fabricated data: release
                // builds surface a real error instead (see #else).
                try? await Task.sleep(for: .seconds(1.2))
                result = AIService.mockResult()
                #else
                throw AIError.notConfigured
                #endif
            }
        } catch {
            errorMessage = (error as? AIError)?.errorDescription ?? error.localizedDescription
            phase = .error
            Haptics.error()
            return
        }

        apply(result)
        phase = .review
        Haptics.success()
    }

    private func apply(_ result: AIScanResult) {
        title = result.title
        mealType = result.suggestedMealType
        items = result.items
        confidence = result.confidence
    }

    func addItem() {
        items.append(AIScanItem(name: "New item", quantity: 1, unit: "serving"))
    }

    func removeItem(_ id: UUID) {
        items.removeAll { $0.id == id }
    }

    func binding(for item: AIScanItem) -> Binding<AIScanItem> {
        Binding(
            get: { self.items.first(where: { $0.id == item.id }) ?? item },
            set: { newValue in
                if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                    self.items[index] = newValue
                }
            }
        )
    }

    @MainActor
    func save(context: ModelContext, health: HealthKitService, streak: Streak?) -> Int? {
        let entry = FoodEntry(
            name: title.trimmingCharacters(in: .whitespaces).isEmpty ? "Meal" : title,
            mealType: mealType,
            source: mode == .label ? .aiLabel : .aiPhoto,
            loggedAt: loggedAt
        )
        entry.totalKcal = totalKcal
        entry.protein = totalProtein
        entry.carbs = totalCarbs
        entry.fat = totalFat
        entry.fiber = totalFiber
        entry.confidence = confidence
        entry.photoData = image?.jpegForUpload(maxDimension: 800, quality: 0.6)
        entry.ingredients = items.map {
            Ingredient(name: $0.name, quantity: $0.quantity, unit: $0.unit,
                       kcal: $0.kcal, protein: $0.protein, carbs: $0.carbs,
                       fat: $0.fat, fiber: $0.fiber)
        }
        entry.day = Self.fetchOrCreateDay(context: context, date: loggedAt)

        context.insert(entry)
        let advanced = DiaryStore.registerStreak(streak, on: loggedAt, in: context)
        try? context.save()

        ScanQuota.record()
        let saved = entry
        Task { await health.save(foodEntry: saved) }
        Haptics.success()
        return advanced
    }

    @MainActor
    private static func fetchOrCreateDay(context: ModelContext, date: Date) -> DiaryDay {
        let start = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<DiaryDay>(predicate: #Predicate { $0.date == start })
        if let existing = try? context.fetch(descriptor).first { return existing }
        let day = DiaryDay(date: start)
        context.insert(day)
        return day
    }
}
