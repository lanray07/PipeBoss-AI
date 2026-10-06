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
    @Published private(set) var hasRefreshedEntitlements = false
    @Published private(set) var hasAttemptedProductLoad = false
    @Published private(set) var productLoadMessage: String?
    @Published var isLoading = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var isRestoring = false
    @Published private(set) var completedPurchaseID: String?
    @Published private(set) var restoreCount = 0
    @Published private(set) var restoreFailureCode: String?
    @Published var restoreNotice: String?
    @Published var errorMessage: String?

    private var transactionUpdates: Task<Void, Never>?
    private var productLoadTask: Task<Void, Never>?
    private var productLoadTimeoutTask: Task<Void, Never>?
    private var activeProductLoadID: UUID?
    private let synchronizePurchases: @MainActor () async throws -> Void
    private let productLoadTimeoutNanoseconds: UInt64 = 12_000_000_000
    private var expectedProductIDs: [String] {
        AppContent.storeProducts.map(\.productID)
    }

    var missingProductCount: Int {
        let loadedIDs = Set(products.map(\.id))
        return expectedProductIDs.filter { !loadedIDs.contains($0) }.count
    }

    init(synchronizePurchases: @escaping @MainActor () async throws -> Void = { try await AppStore.sync() },
         observeTransactions: Bool = true) {
        self.synchronizePurchases = synchronizePurchases
        if observeTransactions {
            transactionUpdates = listenForTransactions()
            Task { [weak self] in await self?.refreshPurchasedProducts() }
        }
    }

    var annualSavingsPercent: Int? {
        guard let monthly = products.first(where: { $0.id == AppContent.ProductIDs.proMonthly }),
              let yearly = products.first(where: { $0.id == AppContent.ProductIDs.proYearly }),
              monthly.subscription?.subscriptionPeriod.unit == .month,
              monthly.subscription?.subscriptionPeriod.value == 1,
              yearly.subscription?.subscriptionPeriod.unit == .year,
              yearly.subscription?.subscriptionPeriod.value == 1 else { return nil }
        return SubscriptionPricing.annualSavingsPercent(
            monthly: monthly.price,
            yearly: yearly.price,
            sameCurrency: monthly.priceFormatStyle.currencyCode == yearly.priceFormatStyle.currencyCode
        )
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
        restoreNotice = nil

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
        guard !isPurchasing, !isRestoring else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        errorMessage = nil
        completedPurchaseID = nil
        restoreNotice = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshPurchasedProducts()
                await transaction.finish()
                completedPurchaseID = product.id
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
        guard !isRestoring, !isPurchasing else { return }
        isRestoring = true
        defer { isRestoring = false }
        errorMessage = nil
        restoreNotice = nil
        restoreFailureCode = nil
        do {
            try await synchronizePurchases()
            await refreshPurchasedProducts()
            restoreCount += 1
            restoreNotice = L10n.text(purchasedProductIDs.isEmpty
                ? AppContent.copy.paywall.restoreNoPurchasesMessage
                : AppContent.copy.paywall.restoreCompletedMessage)
            Haptics.success()
        } catch {
            // A failed server sync must not stop verified on-device entitlement
            // refresh. This also applies refunds/revocations without inventing access.
            await refreshPurchasedProducts()
            let failure = restoreFailure(error)
            guard !failure.cancelled else { return }
            restoreFailureCode = failure.code
            errorMessage = L10n.format(AppContent.copy.paywall.restoreFailureWithCode,
                ["message": L10n.text(failure.message), "code": failure.code])
            Haptics.error()
        }
    }

    private func restoreFailure(_ error: Error, depth: Int = 0) -> (cancelled: Bool, message: String, code: String) {
        if error is CancellationError { return (true, "", "") }
        if let storeError = error as? StoreKitError {
            switch storeError {
            case .userCancelled:
                return (true, "", "")
            case .networkError(let networkError):
                return restoreFailure(networkError, depth: depth + 1)
            case .systemError(let underlying) where depth < 3:
                return restoreFailure(underlying, depth: depth + 1)
            case .unknown:
                return (false, AppContent.copy.paywall.restoreFailedMessage, "StoreKit.unknown")
            default:
                break
            }
        }
        let nsError = error as NSError
        if nsError.domain == SKErrorDomain && nsError.code == SKError.Code.paymentCancelled.rawValue {
            return (true, "", "")
        }
        if nsError.domain == NSURLErrorDomain {
            if nsError.code == URLError.cancelled.rawValue { return (true, "", "") }
            let authenticationCodes = [URLError.userAuthenticationRequired.rawValue, URLError.userCancelledAuthentication.rawValue]
            return (false, authenticationCodes.contains(nsError.code)
                ? AppContent.copy.paywall.restoreAuthenticationMessage
                : AppContent.copy.paywall.restoreNetworkMessage,
                "Network.\(nsError.code)")
        }
        // Support reference only: never expose localized descriptions, URLs,
        // account identifiers, transaction data, or the error's userInfo payload.
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
        let domain = String(String.UnicodeScalarView(nsError.domain.unicodeScalars.filter { allowed.contains($0) }.prefix(80)))
        return (false, AppContent.copy.paywall.restoreFailedMessage, "\(domain.isEmpty ? "Store" : domain).\(nsError.code)")
    }

    func refreshPurchasedProducts() async {
        var purchasedIDs = Set<String>()
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            purchasedIDs.insert(transaction.productID)
        }
        hasRefreshedEntitlements = true
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
                await refreshPurchasedProducts()
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
