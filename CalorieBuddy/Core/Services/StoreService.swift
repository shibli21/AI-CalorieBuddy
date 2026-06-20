//
//  StoreService.swift
//  CalorieBuddy
//
//  StoreKit 2 wrapper. Exposes the Pro entitlement and the available products.
//  Product IDs must match App Store Connect / Configuration.storekit.
//

import Foundation
import StoreKit
import Observation

@Observable
final class StoreService {
    static let weeklyID = "com.shibli21.caloriebuddy.pro.weekly"
    static let annualID = "com.shibli21.caloriebuddy.pro.annual"
    static let productIDs = [weeklyID, annualID]

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false

    var isPro: Bool { !purchasedProductIDs.isEmpty }

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Loading

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await Product.products(for: Self.productIDs)
            // Annual first (best value), then weekly.
            products = loaded.sorted { $0.price > $1.price }
        } catch {
            products = []
        }
    }

    func refreshEntitlements() async {
        var owned = Set<String>()
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                owned.insert(transaction.productID)
            }
        }
        purchasedProductIDs = owned
    }

    // MARK: - Purchase / restore

    enum PurchaseOutcome { case success, pending, cancelled, failed }

    @discardableResult
    func purchase(_ product: Product) async -> PurchaseOutcome {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else { return .failed }
                await transaction.finish()
                await refreshEntitlements()
                Haptics.success()
                return .success
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            @unknown default:
                return .failed
            }
        } catch {
            return .failed
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - Transaction stream

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.refreshEntitlements()
            }
        }
    }
}
