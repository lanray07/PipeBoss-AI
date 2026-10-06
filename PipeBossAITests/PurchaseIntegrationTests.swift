import StoreKit
import StoreKitTest
import XCTest
@testable import PipeBossAI

final class PurchaseIntegrationTests: XCTestCase {
    @MainActor
    private func makeSession() throws -> SKTestSession {
        guard ProcessInfo.processInfo.environment["PIPEBOSS_HOSTED_UNIT_TESTS"] == "1" else {
            throw NSError(domain: "PipeBossStoreKitTest", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Hosted tests must configure StoreKit before app-root initialization"])
        }
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "PipeBossAI", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        guard session.disableDialogs else {
            throw NSError(domain: "PipeBossStoreKitTest", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Local StoreKit session could not disable dialogs; refusing to contact the App Store"])
        }
        return session
    }

    @MainActor
    private func loadedManager() async throws -> PurchaseManager {
        let manager = PurchaseManager()
        await manager.loadProducts()
        let deadline = Date().addingTimeInterval(15)
        while manager.isLoading && Date() < deadline {
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertFalse(manager.isLoading, "Product requests must leave loading state")
        XCTAssertEqual(Set(manager.products.map(\.id)), Set(AppContent.storeProducts.map(\.productID)))
        XCTAssertEqual(manager.missingProductCount, 0)
        return manager
    }

    @MainActor
    private func waitForAccess(_ manager: PurchaseManager, id: String, owned: Bool) async throws {
        let deadline = Date().addingTimeInterval(12)
        repeat {
            await manager.refreshPurchasedProducts()
            if manager.purchasedProductIDs.contains(id) == owned { return }
            try await Task.sleep(nanoseconds: 100_000_000)
        } while Date() < deadline
        XCTFail("Entitlement \(id) did not become \(owned ? "owned" : "unowned")")
    }

    @MainActor
    func testAllSixProductsLoadWithoutChangingFixturePrices() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        let catalogue = try await Product.products(for: AppContent.storeProducts.map(\.productID))
        XCTAssertEqual(Set(catalogue.map(\.id)), Set(AppContent.storeProducts.map(\.productID)),
                       "Direct StoreKit catalogue must load before testing PurchaseManager")
        let manager = try await loadedManager()
        let prices: [String: Decimal] = [
            AppContent.ProductIDs.proMonthly: Decimal(string: "6.99")!,
            AppContent.ProductIDs.proYearly: Decimal(string: "49.99")!,
            AppContent.ProductIDs.cityExpansion: Decimal(string: "9.99")!,
            AppContent.ProductIDs.advancedTools: Decimal(string: "7.99")!,
            AppContent.ProductIDs.emergencyJobs: Decimal(string: "5.99")!,
            AppContent.ProductIDs.businessOwnerMode: Decimal(string: "11.99")!
        ]
        for product in manager.products {
            XCTAssertEqual(product.price, prices[product.id])
        }
    }

    @MainActor
    func testLocalSessionCreatesOnlyXcodeTransactions() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        let id = AppContent.ProductIDs.cityExpansion
        let transaction = try await session.buyProduct(identifier: id, options: [])
        XCTAssertEqual(transaction.productID, id)
        XCTAssertEqual(transaction.environment, .xcode)
        XCTAssertEqual(session.allTransactions().filter { $0.productIdentifier == id }.count, 1)
        await transaction.finish()
    }

    @MainActor
    func testBothSubscriptionsPurchaseAndExpire() async throws {
        for id in [AppContent.ProductIDs.proMonthly, AppContent.ProductIDs.proYearly] {
            let session = try makeSession()
            defer { session.clearTransactions() }
            let manager = try await loadedManager()
            let product = try XCTUnwrap(manager.products.first { $0.id == id })
            await manager.purchase(product)
            XCTAssertEqual(manager.completedPurchaseID, id)
            XCTAssertNil(manager.errorMessage)
            try await waitForAccess(manager, id: id, owned: true)
            XCTAssertFalse(manager.isPurchasing)
            try session.expireSubscription(productIdentifier: id)
            try await waitForAccess(manager, id: id, owned: false)
        }
    }

    @MainActor
    func testEveryPackUnlocksContentAndRefundRemovesAccess() async throws {
        for id in [AppContent.ProductIDs.cityExpansion, AppContent.ProductIDs.advancedTools,
                   AppContent.ProductIDs.emergencyJobs, AppContent.ProductIDs.businessOwnerMode] {
            let session = try makeSession()
            defer { session.clearTransactions() }
            let manager = try await loadedManager()
            let product = try XCTUnwrap(manager.products.first { $0.id == id })
            await manager.purchase(product)
            XCTAssertEqual(manager.completedPurchaseID, id)
            try await waitForAccess(manager, id: id, owned: true)
            let defaults = try XCTUnwrap(UserDefaults(suiteName: "pipeboss.storekit.tests.\(UUID())"))
            let store = UserDefaultsProgressStore(defaults: defaults)
            defer { store.clear() }
            let game = GameViewModel(store: store)
            game.syncEntitlements(manager.purchasedProductIDs)
            if id == AppContent.ProductIDs.advancedTools {
                XCTAssertTrue(PackContent.specialistToolIDs.allSatisfy { game.ownsTool($0) })
            } else {
                let jobs = PackContent.jobs(for: id, in: game.jobs)
                XCTAssertFalse(jobs.isEmpty)
                XCTAssertTrue(jobs.allSatisfy { game.hasContentAccess(to: $0) })
            }
            let transaction = try XCTUnwrap(session.allTransactions().last { $0.productIdentifier == id })
            try session.refundTransaction(identifier: transaction.identifier)
            try await waitForAccess(manager, id: id, owned: false)
            game.syncEntitlements(manager.purchasedProductIDs)
            XCTAssertFalse(game.hasEntitlement(id))
            if id == AppContent.ProductIDs.advancedTools {
                XCTAssertFalse(PackContent.specialistToolIDs.contains { game.ownsTool($0) })
            } else {
                let paidJobs = PackContent.jobs(for: id, in: game.jobs).filter { !$0.isFreeStarterJob }
                XCTAssertFalse(paidJobs.isEmpty)
                XCTAssertFalse(paidJobs.contains { game.hasContentAccess(to: $0) })
            }
        }
    }

    @MainActor
    func testRelaunchAndRestoreRetainOwnedPack() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        let manager = try await loadedManager()
        let id = AppContent.ProductIDs.cityExpansion
        let product = try XCTUnwrap(manager.products.first { $0.id == id })
        await manager.purchase(product)
        try await waitForAccess(manager, id: id, owned: true)
        let restoredManager = PurchaseManager()
        restoredManager.errorMessage = "Previous request failed"
        await restoredManager.restorePurchases()
        try await waitForAccess(restoredManager, id: id, owned: true)
        XCTAssertEqual(restoredManager.restoreCount, 1)
        XCTAssertFalse(restoredManager.isRestoring)
        XCTAssertNil(restoredManager.errorMessage)
        XCTAssertEqual(restoredManager.restoreNotice, AppContent.copy.paywall.restoreCompletedMessage)
    }

    @MainActor
    func testRestoreSyncFailureStillRefreshesVerifiedEntitlementsAndReportsCause() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        let id = AppContent.ProductIDs.businessOwnerMode
        let manager = try await loadedManager()
        let product = try XCTUnwrap(manager.products.first { $0.id == id })
        await manager.purchase(product)
        try await waitForAccess(manager, id: id, owned: true)

        let restoring = PurchaseManager(synchronizePurchases: {
            throw StoreKitError.unknown
        }, observeTransactions: false)
        // Freeze its starting snapshot. Restore itself must refresh it,
        // even when Apple's synchronization fails after authentication.
        await restoring.refreshPurchasedProducts()
        let transaction = try XCTUnwrap(session.allTransactions().last { $0.productIdentifier == id })
        try session.refundTransaction(identifier: transaction.identifier)
        try await waitForAccess(manager, id: id, owned: false)
        await restoring.restorePurchases()
        XCTAssertFalse(restoring.purchasedProductIDs.contains(id), "Failed sync must still refresh verified entitlements, including refunds")
        XCTAssertEqual(restoring.restoreCount, 0, "An incomplete sync must never be counted as a successful restore")
        XCTAssertEqual(restoring.restoreFailureCode, "StoreKit.unknown")
        XCTAssertNotNil(restoring.errorMessage)
        XCTAssertFalse(restoring.errorMessage?.contains("account used to subscribe") ?? true)
        XCTAssertFalse(restoring.isRestoring)
        XCTAssertNil(restoring.restoreNotice)
    }

    @MainActor
    func testCancelledRestoreDoesNotReportFailureOrSuccess() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        let manager = PurchaseManager(synchronizePurchases: { throw StoreKitError.userCancelled })
        await manager.restorePurchases()
        XCTAssertNil(manager.errorMessage)
        XCTAssertNil(manager.restoreFailureCode)
        XCTAssertEqual(manager.restoreCount, 0)
        XCTAssertFalse(manager.isRestoring)
        XCTAssertNil(manager.restoreNotice)
    }

    @MainActor
    func testFailedSyncLoadsExistingVerifiedPackWithoutClaimingSyncSucceeded() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        let id = AppContent.ProductIDs.emergencyJobs
        let transaction = try await session.buyProduct(identifier: id, options: [])
        await transaction.finish()
        let manager = PurchaseManager(synchronizePurchases: { throw StoreKitError.unknown }, observeTransactions: false)
        XCTAssertTrue(manager.purchasedProductIDs.isEmpty)
        await manager.restorePurchases()
        XCTAssertTrue(manager.purchasedProductIDs.contains(id))
        XCTAssertEqual(manager.restoreCount, 0)
        XCTAssertNil(manager.restoreNotice)
        XCTAssertEqual(manager.restoreFailureCode, "StoreKit.unknown")
        XCTAssertNotNil(manager.errorMessage)
    }

    @MainActor
    func testRestoreNetworkFailureThenSuccessfulRetryClearsErrorAndConfirmsResult() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        var shouldFail = true
        let manager = PurchaseManager(synchronizePurchases: {
            if shouldFail { throw StoreKitError.networkError(URLError(.notConnectedToInternet)) }
        }, observeTransactions: false)
        await manager.restorePurchases()
        XCTAssertEqual(manager.restoreFailureCode, "Network.-1009")
        XCTAssertTrue(manager.errorMessage?.contains(AppContent.copy.paywall.restoreNetworkMessage) ?? false)
        XCTAssertEqual(manager.restoreCount, 0)
        shouldFail = false
        await manager.restorePurchases()
        XCTAssertNil(manager.restoreFailureCode)
        XCTAssertNil(manager.errorMessage)
        XCTAssertEqual(manager.restoreNotice, AppContent.copy.paywall.restoreNoPurchasesMessage)
        XCTAssertEqual(manager.restoreCount, 1)
        XCTAssertFalse(manager.isRestoring)
    }

    @MainActor
    func testRestoreDiagnosticsDoNotExposeUnderlyingUserInfo() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        let manager = PurchaseManager(synchronizePurchases: {
            throw StoreKitError.systemError(NSError(domain: "StoreService", code: 7,
                userInfo: [NSLocalizedDescriptionKey: "PRIVATE_ACCOUNT_OR_TRANSACTION_DETAIL"]))
        }, observeTransactions: false)
        await manager.restorePurchases()
        XCTAssertEqual(manager.restoreFailureCode, "StoreService.7")
        XCTAssertFalse(manager.errorMessage?.contains("PRIVATE_ACCOUNT_OR_TRANSACTION_DETAIL") ?? true)
    }

    @MainActor
    func testFailedPurchaseDoesNotGrantAccessOrRemainBusy() async throws {
        let session = try makeSession()
        defer { session.clearTransactions() }
        let manager = try await loadedManager()
        let previousID = AppContent.ProductIDs.cityExpansion
        let previousProduct = try XCTUnwrap(manager.products.first { $0.id == previousID })
        await manager.purchase(previousProduct)
        try await waitForAccess(manager, id: previousID, owned: true)
        session.failTransactionsEnabled = true
        let id = AppContent.ProductIDs.emergencyJobs
        let product = try XCTUnwrap(manager.products.first { $0.id == id })
        await manager.purchase(product)
        XCTAssertFalse(manager.isPurchasing)
        XCTAssertFalse(manager.purchasedProductIDs.contains(id))
        XCTAssertTrue(manager.purchasedProductIDs.contains(previousID))
        XCTAssertNil(manager.completedPurchaseID)
        XCTAssertNotNil(manager.errorMessage)
    }
}
