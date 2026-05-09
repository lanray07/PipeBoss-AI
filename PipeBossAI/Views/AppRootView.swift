import SwiftUI

enum AppTab: Hashable {
    case home
    case jobs
    case tools
    case learn
    case business
}

struct AppRootView: View {
    @StateObject private var game = GameViewModel()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some View {
        Group {
            if game.player.hasCompletedOnboarding {
                MainTabView(game: game, purchaseManager: purchaseManager)
            } else {
                OnboardingView(game: game)
            }
        }
        .task {
            await purchaseManager.loadProducts()
            game.syncEntitlements(purchaseManager.purchasedProductIDs)
        }
        .onReceive(purchaseManager.$purchasedProductIDs) { productIDs in
            game.syncEntitlements(productIDs)
        }
        .alert("PipeBoss AI", isPresented: alertBinding) {
            Button(AppContent.copy.ok, role: .cancel) {
                game.alertMessage = nil
            }
        } message: {
            Text(game.alertMessage ?? "")
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
                Label(AppContent.copy.tabs.home, systemImage: "house.fill")
            }
            .tag(AppTab.home)

            NavigationStack {
                JobBoardView(game: game)
            }
            .tabItem {
                Label(AppContent.copy.tabs.jobs, systemImage: "list.bullet.clipboard.fill")
            }
            .tag(AppTab.jobs)

            NavigationStack {
                ToolInventoryView(game: game)
            }
            .tabItem {
                Label(AppContent.copy.tabs.tools, systemImage: "wrench.and.screwdriver.fill")
            }
            .tag(AppTab.tools)

            NavigationStack {
                LearningCardsView(game: game)
            }
            .tabItem {
                Label(AppContent.copy.tabs.learn, systemImage: "book.pages.fill")
            }
            .tag(AppTab.learn)

            NavigationStack {
                BusinessUpgradeView(game: game, purchaseManager: purchaseManager)
            }
            .tabItem {
                Label(AppContent.copy.tabs.business, systemImage: "briefcase.fill")
            }
            .tag(AppTab.business)
        }
        .tint(AppTheme.orange)
        .sheet(isPresented: $game.showPaywall) {
            PaywallView(game: game, purchaseManager: purchaseManager)
        }
    }
}
