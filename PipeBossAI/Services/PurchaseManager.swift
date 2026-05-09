import Foundation
import StoreKit

#if canImport(UIKit)
import UIKit
#endif

enum StoreError: Error {
    case failedVerification
}

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var transactionUpdates: Task<Void, Never>?

    init() {
        transactionUpdates = listenForTransactions()
    }

    deinit {
        transactionUpdates?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: AppContent.storeProducts.map(\.productID))
            await refreshPurchasedProducts()
        } catch {
            errorMessage = AppContent.copy.paywall.storeUnavailableMessage
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                Haptics.success()
            case .userCancelled:
                break
            case .pending:
                errorMessage = AppContent.copy.paywall.pendingPurchaseMessage
            @unknown default:
                errorMessage = AppContent.copy.paywall.storeUnavailableMessage
            }
        } catch {
            errorMessage = AppContent.copy.paywall.storeUnavailableMessage
            Haptics.error()
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshPurchasedProducts()
            Haptics.success()
        } catch {
            errorMessage = AppContent.copy.paywall.restoreFailedMessage
        }
    }

    func refreshPurchasedProducts() async {
        var purchasedIDs = Set<String>()
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            purchasedIDs.insert(transaction.productID)
        }
        purchasedProductIDs = purchasedIDs
    }

    func manageSubscriptions() async {
        #if canImport(UIKit)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            errorMessage = AppContent.copy.paywall.manageUnavailableMessage
            return
        }

        do {
            try await AppStore.showManageSubscriptions(in: scene)
        } catch {
            errorMessage = AppContent.copy.paywall.manageUnavailableMessage
        }
        #else
        errorMessage = AppContent.copy.paywall.manageUnavailableMessage
        #endif
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                guard let transaction = try? checkVerified(result) else { continue }
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
