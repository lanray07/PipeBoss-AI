import Combine
import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published var player: Player {
        didSet { store.save(player) }
    }

    @Published var showPaywall = false
    @Published var alertMessage: String?

    let jobs = AppContent.jobs
    let tools = AppContent.tools
    let upgrades = AppContent.upgrades
    let learningCards = AppContent.learningCards

    private let store: ProgressStoring

    init(store: ProgressStoring = UserDefaultsProgressStore()) {
        self.store = store
        var loadedPlayer = store.loadPlayer()
        loadedPlayer.refreshEnergyIfNeeded()
        self.player = loadedPlayer
        unlockLearningCardsForProgress()
    }

    var hasProAccess: Bool {
        player.hasPipeBossPro
    }

    var completedJobs: [JobScenario] {
        jobs.filter { player.completedJobIDs.contains($0.id) }
    }

    var nextRecommendedJob: JobScenario? {
        jobs.first { canStart($0) && !player.completedJobIDs.contains($0.id) }
    }

    var unlockedLearningCards: [LearningCard] {
        learningCards.filter { player.unlockedLearningCardIDs.contains($0.id) }
    }

    func completeOnboarding(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        player.name = trimmedName.isEmpty ? Player.newApprentice.name : trimmedName
        player.hasCompletedOnboarding = true
    }

    func resetProgress() {
        store.clear()
        player = Player.newApprentice
    }

    func syncEntitlements(_ productIDs: Set<String>) {
        player.activeEntitlements = Array(productIDs).sorted()

        if productIDs.contains(AppContent.ProductIDs.advancedTools) {
            grantTools(["inspection-camera", "pipe-freeze-kit", "press-tool", "thermal-camera", "drain-camera"])
        }

        unlockLearningCardsForProgress()
    }

    func hasEntitlement(_ productID: String) -> Bool {
        player.activeEntitlements.contains(productID)
    }

    func tool(withID id: String) -> ToolItem? {
        tools.first { $0.id == id }
    }

    func upgrade(withID id: String) -> Upgrade? {
        upgrades.first { $0.id == id }
    }

    func ownsTool(_ toolID: String) -> Bool {
        player.ownedToolIDs.contains(toolID)
    }

    func ownsUpgrade(_ upgradeID: String) -> Bool {
        player.purchasedUpgradeIDs.contains(upgradeID)
    }

    func missingTools(for job: JobScenario) -> [ToolItem] {
        job.requiredTools.compactMap { id in
            guard !player.ownedToolIDs.contains(id) else { return nil }
            return tool(withID: id)
        }
    }

    func isJobUnlocked(_ job: JobScenario) -> Bool {
        guard player.level >= job.requiredLevel else { return false }
        if hasProAccess { return true }
        if job.isFreeStarterJob { return true }
        if job.category == .emergency && hasEntitlement(AppContent.ProductIDs.emergencyJobs) { return true }
        if job.category == .business && hasEntitlement(AppContent.ProductIDs.businessOwnerMode) { return true }
        if [.commercial, .installation].contains(job.category) && hasEntitlement(AppContent.ProductIDs.cityExpansion) { return true }
        return false
    }

    func canStart(_ job: JobScenario) -> Bool {
        isJobUnlocked(job)
            && missingTools(for: job).isEmpty
            && (hasProAccess || player.energy > 0)
    }

    func lockReason(for job: JobScenario) -> String? {
        if player.level < job.requiredLevel {
            return "Reach level \(job.requiredLevel)"
        }

        if !isJobUnlocked(job) {
            return job.isPremium ? "PipeBoss Pro or expansion required" : "Free plan includes the first 10 beginner jobs"
        }

        let missing = missingTools(for: job)
        if !missing.isEmpty {
            return "Need \(missing.map(\.name).joined(separator: ", "))"
        }

        if !hasProAccess && player.energy == 0 {
            return "Energy empty"
        }

        return nil
    }

    func buyTool(_ tool: ToolItem) {
        guard !ownsTool(tool.id) else { return }
        guard player.level >= tool.requiredLevel else {
            alertMessage = "Reach level \(tool.requiredLevel) to unlock \(tool.name)."
            Haptics.warning()
            return
        }
        guard player.coins >= tool.cost else {
            alertMessage = "Earn more coins before buying \(tool.name)."
            Haptics.warning()
            return
        }

        player.coins -= tool.cost
        player.ownedToolIDs.append(tool.id)
        Haptics.success()
    }

    func buyUpgrade(_ upgrade: Upgrade) {
        guard !ownsUpgrade(upgrade.id) else { return }

        if upgrade.isPremium && !hasProAccess && !hasEntitlement(AppContent.ProductIDs.businessOwnerMode) {
            showPaywall = true
            return
        }

        guard player.level >= upgrade.requiredLevel else {
            alertMessage = "Reach level \(upgrade.requiredLevel) to unlock \(upgrade.name)."
            Haptics.warning()
            return
        }

        guard player.coins >= upgrade.cost else {
            alertMessage = "Earn more coins before buying \(upgrade.name)."
            Haptics.warning()
            return
        }

        player.coins -= upgrade.cost
        player.purchasedUpgradeIDs.append(upgrade.id)

        if upgrade.id == "scheduling-tablet" {
            player.maxEnergy += 1
            player.energy = min(player.maxEnergy, player.energy + 1)
        }

        Haptics.success()
    }

    func claimRewardedAdReward(_ reward: RewardedAdReward) {
        guard !hasProAccess else { return }

        switch reward {
        case .coins:
            player.coins += 60
        case .energy:
            player.energy = min(player.maxEnergy, player.energy + 2)
        case .hint:
            break
        }

        Haptics.success()
    }

    func completeJob(_ job: JobScenario, diagnosisCorrect: Bool, repairCorrect: Bool, remainingSeconds: Int) -> JobOutcome {
        let perfect = diagnosisCorrect && repairCorrect && remainingSeconds > 0
        var xpAwarded = perfect ? job.rewardXP : max(20, job.rewardXP / (repairCorrect ? 2 : 4))
        var coinsAwarded = perfect ? job.rewardCoins : max(0, job.rewardCoins / (repairCorrect ? 2 : 5))

        if ownsUpgrade("apprentice-course"), repairCorrect {
            xpAwarded += 10
        }

        if ownsUpgrade("parts-bins"), job.difficulty == .beginner {
            coinsAwarded = Int(Double(coinsAwarded) * 1.05)
        }

        var reputationChange: Double
        if perfect {
            reputationChange = ownsUpgrade("branded-van") ? 0.22 : 0.12
        } else if repairCorrect {
            reputationChange = 0.02
        } else {
            reputationChange = -0.18
        }

        if ownsUpgrade("review-system"), reputationChange > 0 {
            reputationChange *= 1.05
        }

        player.xp += xpAwarded
        player.coins += coinsAwarded
        player.reputation = min(5.0, max(1.0, player.reputation + reputationChange))

        if !hasProAccess {
            player.energy = max(0, player.energy - 1)
            player.dailyJobCount += 1
        }

        if repairCorrect && !player.completedJobIDs.contains(job.id) {
            player.completedJobIDs.append(job.id)
        }

        unlockLearningCardsForProgress()

        let message: String
        if perfect {
            message = "Clean fix. The customer leaves a strong review."
        } else if repairCorrect {
            message = "Repair completed, but the job needed rework or extra explanation."
        } else {
            message = "The fault is not fully resolved. Review the diagnosis and try again."
        }

        return JobOutcome(
            jobID: job.id,
            jobTitle: job.title,
            diagnosisCorrect: diagnosisCorrect,
            repairCorrect: repairCorrect,
            xpAwarded: xpAwarded,
            coinsAwarded: coinsAwarded,
            rating: player.reputation,
            reputationChange: reputationChange,
            message: message,
            learningTip: job.learningTip,
            safetyWarning: job.safetyWarning
        )
    }

    private func grantTools(_ toolIDs: [String]) {
        for toolID in toolIDs where !player.ownedToolIDs.contains(toolID) {
            player.ownedToolIDs.append(toolID)
        }
    }

    private func unlockLearningCardsForProgress() {
        for card in learningCards {
            guard card.requiredLevel <= player.level else { continue }
            guard !card.isPremium || hasProAccess else { continue }
            guard !player.unlockedLearningCardIDs.contains(card.id) else { continue }
            player.unlockedLearningCardIDs.append(card.id)
        }
    }
}
