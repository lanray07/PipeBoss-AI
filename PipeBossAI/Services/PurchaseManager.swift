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
    @Published private(set) var hasAttemptedProductLoad = false
    @Published private(set) var productLoadMessage: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var transactionUpdates: Task<Void, Never>?
    private var productLoadTask: Task<Void, Never>?
    private var productLoadTimeoutTask: Task<Void, Never>?
    private var activeProductLoadID: UUID?
    private let productLoadTimeoutNanoseconds: UInt64 = 12_000_000_000
    private var expectedProductIDs: [String] {
        AppContent.storeProducts.map(\.productID)
    }

    var missingProductCount: Int {
        let loadedIDs = Set(products.map(\.id))
        return expectedProductIDs.filter { !loadedIDs.contains($0) }.count
    }

    init() {
        transactionUpdates = listenForTransactions()
    }

    deinit {
        transactionUpdates?.cancel()
        productLoadTask?.cancel()
        productLoadTimeoutTask?.cancel()
    }

    func loadProducts() async {
        guard !isLoading else { return }

        productLoadTask?.cancel()
        productLoadTimeoutTask?.cancel()

        let loadID = UUID()
        activeProductLoadID = loadID
        isLoading = true
        hasAttemptedProductLoad = true
        productLoadMessage = nil
        errorMessage = nil

        let requestedProductIDs = expectedProductIDs
        let timeoutNanoseconds = productLoadTimeoutNanoseconds
        productLoadTask = Task { [weak self, requestedProductIDs] in
            do {
                let fetchedProducts = try await Product.products(for: requestedProductIDs)
                await self?.completeProductLoad(
                    loadID: loadID,
                    fetchedProducts: fetchedProducts,
                    requestedProductIDs: requestedProductIDs
                )
            } catch is CancellationError {
                await self?.cancelProductLoad(loadID: loadID)
            } catch {
                await self?.failProductLoad(loadID: loadID)
            }
        }

        productLoadTimeoutTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: timeoutNanoseconds)
                await self?.failProductLoad(loadID: loadID)
            } catch {
                return
            }
        }
    }

    private func completeProductLoad(
        loadID: UUID,
        fetchedProducts: [Product],
        requestedProductIDs: [String]
    ) {
        guard activeProductLoadID == loadID else { return }

        isLoading = false
        activeProductLoadID = nil
        productLoadTask = nil
        productLoadTimeoutTask?.cancel()
        productLoadTimeoutTask = nil

        let productOrder = Dictionary(uniqueKeysWithValues: requestedProductIDs.enumerated().map { ($0.element, $0.offset) })
        products = fetchedProducts.sorted {
            (productOrder[$0.id] ?? Int.max) < (productOrder[$1.id] ?? Int.max)
        }
        if missingProductCount > 0 {
            productLoadMessage = AppContent.copy.paywall.storeUnavailableMessage
        }

        Task { [weak self] in
            await self?.refreshPurchasedProducts()
        }
    }

    private func failProductLoad(loadID: UUID) {
        guard activeProductLoadID == loadID else { return }

        productLoadTask?.cancel()
        productLoadTimeoutTask?.cancel()
        productLoadTask = nil
        productLoadTimeoutTask = nil
        activeProductLoadID = nil
        isLoading = false
        products = []
        productLoadMessage = AppContent.copy.paywall.storeUnavailableMessage
    }

    private func cancelProductLoad(loadID: UUID) {
        guard activeProductLoadID == loadID else { return }

        productLoadTask = nil
        productLoadTimeoutTask?.cancel()
        productLoadTimeoutTask = nil
        activeProductLoadID = nil
        isLoading = false
    }

    func product(for product: SubscriptionProduct) -> Product? {
        products.first { $0.id == product.productID }
    }

    func purchase(_ product: Product) async {
        errorMessage = nil
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
