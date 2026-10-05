#if DEBUG
import SwiftUI

// Debug-only launch fixture for real Simulator screenshots, never entitlement bypass in Release.
struct ScreenshotPreview: View {
    let screen: String
    @StateObject private var game: GameViewModel
    @StateObject private var purchaseManager = PurchaseManager()

    init(screen: String) {
        self.screen = screen
        let suite = "pipeboss.screenshot.preview"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let model = GameViewModel(store: UserDefaultsProgressStore(defaults: defaults))
        model.completeOnboarding(name: "Alex")
        model.player.xp = 960
        model.player.coins = 1840
        model.player.ownedToolIDs += ["pipe-cutter", "drain-auger", "pressure-gauge"]
        model.syncEntitlements([AppContent.ProductIDs.proMonthly])
        let job = AppContent.jobs[0]
        model.recordTraining(job: job, diagnosisID: "wrong", repairID: "wrong", mode: .career)
        _game = StateObject(wrappedValue: model)
    }

    var body: some View {
        NavigationStack {
            switch screen {
            case "diagnosis": JobSimulationView(game: game, job: AppContent.jobs[0], preview: .diagnose)
            case "result": JobSimulationView(game: game, job: AppContent.jobs[0], preview: .result)
            case "skills": SkillsView(game: game)
            case "tools": ToolInventoryView(game: game)
            case "learning": LearningCardsView(game: game)
            case "packs": BusinessUpgradeView(game: game, purchaseManager: purchaseManager)
            default: DashboardView(game: game)
            }
        }.tint(AppTheme.orange)
    }
}
#endif
