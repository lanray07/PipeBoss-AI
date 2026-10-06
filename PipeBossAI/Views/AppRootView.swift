import SwiftUI

enum AppTab: Hashable {
    case home
    case jobs
    case tools
    case learn
    case business
}

struct AppRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var game = GameViewModel()
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var localization = LocalizationPreferences()

    var body: some View {
        Group {
            #if DEBUG
            if let index = ProcessInfo.processInfo.arguments.firstIndex(of: "--capture-screen"),
               ProcessInfo.processInfo.arguments.indices.contains(index + 1) {
                ScreenshotPreview(screen: ProcessInfo.processInfo.arguments[index + 1])
            } else {
                appContent
            }
            #else
            appContent
            #endif
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                game.refreshDailyEnergy()
                Task { await purchaseManager.refreshPurchasedProducts() }
            }
        }
        .task {
            if !ProcessInfo.processInfo.arguments.contains("--capture-screen") {
                await purchaseManager.loadProducts()
            }
        }
        .onReceive(purchaseManager.$purchasedProductIDs) { productIDs in
            if purchaseManager.hasRefreshedEntitlements {
                game.syncEntitlements(productIDs)
            }
        }
        .onReceive(purchaseManager.$completedPurchaseID.dropFirst()) { productID in
            if let productID { game.training.recordEvent("purchase.verified.\(productID)") }
        }
        .onReceive(purchaseManager.$restoreCount.dropFirst()) { _ in
            game.training.recordEvent("restore.completed")
        }
        .alert(LocalizedStringKey("PipeBoss AI"), isPresented: alertBinding) {
            Button(LocalizedStringKey(AppContent.copy.ok), role: .cancel) {
                game.alertMessage = nil
            }
        } message: {
            LText(game.alertMessage ?? "")
        }
        .environmentObject(localization)
        .environment(\.locale, localization.locale)
    }

    private var appContent: some View {
        Group {
            if game.player.hasCompletedOnboarding {
                MainTabView(game: game, purchaseManager: purchaseManager)
            } else {
                OnboardingView(game: game)
            }
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { game.alertMessage != nil },
            set: { isPresented in
                if !isPresented { game.alertMessage = nil }
            }
        )
    }
}

struct MainTabView: View {
    @ObservedObject var game: GameViewModel
    @ObservedObject var purchaseManager: PurchaseManager
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(game: game)
            }
            .tabItem {
                LLabel(AppContent.copy.tabs.home, systemImage: "house.fill")
            }
            .tag(AppTab.home)

            NavigationStack {
                JobBoardView(game: game)
            }
            .tabItem {
                LLabel(AppContent.copy.tabs.jobs, systemImage: "list.bullet.clipboard.fill")
            }
            .tag(AppTab.jobs)

            NavigationStack {
                ToolInventoryView(game: game)
            }
            .tabItem {
                LLabel(AppContent.copy.tabs.tools, systemImage: "wrench.and.screwdriver.fill")
            }
            .tag(AppTab.tools)

            NavigationStack {
                LearningCardsView(game: game)
            }
            .tabItem {
                LLabel(AppContent.copy.tabs.learn, systemImage: "book.pages.fill")
            }
            .tag(AppTab.learn)

            NavigationStack {
                BusinessUpgradeView(game: game, purchaseManager: purchaseManager)
            }
            .tabItem {
                LLabel(AppContent.copy.tabs.business, systemImage: "briefcase.fill")
            }
            .tag(AppTab.business)
        }
        .tint(AppTheme.orange)
        .sheet(isPresented: $game.showPaywall) {
            PaywallView(game: game, purchaseManager: purchaseManager)
        }
        .alert(LocalizedStringKey(AppContent.copy.appName), isPresented: Binding(
            get: { !game.showPaywall && purchaseManager.errorMessage != nil },
            set: { if !$0 { purchaseManager.errorMessage = nil } }
        )) {
            Button(LocalizedStringKey(AppContent.copy.ok), role: .cancel) { purchaseManager.errorMessage = nil }
        } message: {
            LText(purchaseManager.errorMessage ?? "")
        }
    }
}
