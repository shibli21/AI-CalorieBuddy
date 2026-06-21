//
//  AppContainer.swift
//  CalorieBuddy
//
//  Builds the SwiftData ModelContainer. CloudKit mirroring is automatic when
//  the iCloud/CloudKit entitlement is present and a container exists.
//

import Foundation
import SwiftData

enum AppContainer {
    static let schema = Schema([
        UserProfile.self,
        DiaryDay.self,
        FoodEntry.self,
        Ingredient.self,
        WaterLog.self,
        WeightEntry.self,
        FastingSession.self,
        Streak.self,
        AwardRecord.self,
        FavoriteFood.self,
        CoachMessage.self,
    ])

    /// Creates the app's container. Falls back to an in-memory store if the
    /// on-disk store can't be opened, so the app always launches.
    static func make(inMemory: Bool = false) -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            if !inMemory {
                assertionFailure("Persistent ModelContainer failed, using in-memory: \(error)")
                return make(inMemory: true)
            }
            fatalError("Unable to create ModelContainer: \(error)")
        }
    }

    /// In-memory container seeded with sample data, for SwiftUI previews.
    @MainActor
    static let preview: ModelContainer = {
        let container = make(inMemory: true)
        SampleData.populate(container.mainContext)
        return container
    }()
}
