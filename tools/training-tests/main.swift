import Foundation

@main
struct TrainingIntegrationChecks {
    @MainActor
    static func main() {
        let suite = "pipeboss.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = UserDefaultsProgressStore(defaults: defaults)
        let game = GameViewModel(store: store)
        game.completeOnboarding(name: "Test")
        let job = AppContent.jobs[0]
        let before = game.player
        game.recordTraining(job: job, diagnosisID: "wrong", repairID: "wrong", mode: .practice)
        precondition(game.player == before, "Practice must not consume energy or modify career economy")
        precondition(game.practiceJobs.contains { $0.id == job.id }, "Mistake queue should appear")
        let vm = JobSimulationViewModel(job: job)
        vm.startInspection(using: game)
        job.requiredTools.forEach { vm.toggleTool($0) }
        vm.moveToDiagnosis()
        vm.selectedDiagnosisID = job.diagnosisQuestion.correctOptionID
        vm.confirmDiagnosis()
        vm.selectedRepairID = job.correctRepairID
        vm.confirmRepair(using: game)
        precondition(game.player.xp == job.rewardXP && game.player.energy == before.energy - 1)
        precondition(game.training.careerAttempts == 1 && game.training.totalAttempts == 2)
        vm.confirmRepair(using: game)
        precondition(game.training.totalAttempts == 2, "Repeated button events must not grant duplicate rewards")
        let restored = GameViewModel(store: store)
        precondition(restored.player == game.player && restored.training == game.training)
        game.syncEntitlements([AppContent.ProductIDs.advancedTools])
        precondition(game.ownsTool("thermal-camera"), "Purchased tool pack grants tools")
        game.syncEntitlements([])
        precondition(!game.ownsTool("thermal-camera"), "Revoked pack no longer grants unearned tools")
        game.syncEntitlements([AppContent.ProductIDs.proMonthly])
        game.resetProgress()
        precondition(game.hasProAccess, "Reset progress must retain current purchases")
        precondition(game.training.totalAttempts == 0, "Reset removes local learning history")
        game.player.activeEntitlements = []
        game.player.energy = 0
        precondition(!game.canStart(job))
        let noEnergy = game.player
        game.recordTraining(job: job, diagnosisID: "wrong", repairID: "wrong", mode: .daily)
        precondition(game.player == noEnergy, "Daily practice stays available without energy")
        print("Passed MVVM persistence, practice, rewards, reset, and purchase-access integration checks.")
    }
}
