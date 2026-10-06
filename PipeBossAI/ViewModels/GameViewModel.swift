import Combine
import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published var player: Player {
        didSet { store.save(player) }
    }

    @Published var showPaywall = false
    @Published var alertMessage: String?
    @Published var training: TrainingProgress {
        didSet { store.saveTraining(training) }
    }

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
        self.training = store.loadTraining()
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

    var practiceJobs: [JobScenario] {
        training.dueJobIDs().compactMap { id in jobs.first { $0.id == id && hasContentAccess(to: $0) } }
    }

    var dailyChallenge: JobScenario? { TrainingProgress.dailyJob(from: jobs) }

    var topicPerformance: [TopicPerformance] {
        JobCategory.allCases.compactMap { category in
            let attempts = training.attempts.filter { $0.category == category }
            return attempts.isEmpty ? nil : TopicPerformance(category: category, attempts: attempts)
        }
    }

    func presentStore(reason: String) {
        training.recordEvent("store.\(reason)")
        showPaywall = true
    }

    func recordTraining(job: JobScenario, diagnosisID: String, repairID: String, mode: TrainingMode) {
        guard hasContentAccess(to: job) else { return }
        training.record(TrainingAttempt(job: job, diagnosisID: diagnosisID, repairID: repairID, mode: mode))
    }

    func recordReviewRequest() { training.reviewRequestDates.append(Date()) }

    func unlockMentorHint() -> Bool {
        if hasProAccess || training.careerAttempts == 0 { return true }
        guard player.coins >= 20 else {
            alertMessage = AppContent.copy.training.hintInsufficient
            return false
        }
        player.coins -= 20
        training.recordEvent("mentor.coinHint")
        return true
    }

    func completeOnboarding(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        player.name = trimmedName.isEmpty ? Player.newApprentice.name : trimmedName
        player.hasCompletedOnboarding = true
        training.recordEvent("onboarding.completed")
    }

    func resetProgress() {
        let entitlements = player.activeEntitlements
        let reviewRequests = training.reviewRequestDates
        store.clear()
        player = Player.newApprentice
        training = TrainingProgress()
        training.reviewRequestDates = reviewRequests
        syncEntitlements(Set(entitlements))
    }

    func refreshDailyEnergy() {
        player.refreshEnergyIfNeeded()
    }

    func syncEntitlements(_ productIDs: Set<String>) {
        player.activeEntitlements = Array(productIDs).sorted()

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
            || (hasEntitlement(AppContent.ProductIDs.advancedTools) && PackContent.specialistToolIDs.contains(toolID))
    }

    func ownsUpgrade(_ upgradeID: String) -> Bool {
        player.purchasedUpgradeIDs.contains(upgradeID)
    }

    func inspectionTimeBonus(for job: JobScenario) -> Int {
        let kitBonus = job.requiredTools.compactMap { tool(withID: $0) }.filter { ownsTool($0.id) }.reduce(0) { $0 + $1.performanceBoost * 5 }
        return min(60, kitBonus) + (job.category == .emergency && ownsUpgrade("emergency-kit") ? 30 : 0)
    }

    func missingTools(for job: JobScenario) -> [ToolItem] {
        job.requiredTools.compactMap { id in
            guard !ownsTool(id) else { return nil }
            return tool(withID: id)
        }
    }

    func isJobUnlocked(_ job: JobScenario) -> Bool {
        player.level >= job.requiredLevel && hasContentAccess(to: job)
    }

    func hasContentAccess(to job: JobScenario) -> Bool {
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

    func lockReason(for job: JobScenario, language: String = L10n.currentLanguage) -> String? {
        if player.level < job.requiredLevel {
            return L10n.format(AppContent.copy.format.reachLevel, ["level": "\(job.requiredLevel)"], language: language)
        }

        if !isJobUnlocked(job) {
            return L10n.text(job.isPremium ? AppContent.copy.feedback.proRequired : AppContent.copy.feedback.freeLimit, language: language)
        }

        let missing = missingTools(for: job)
        if !missing.isEmpty {
            return L10n.format(AppContent.copy.format.needTools, ["tools": missing.map { L10n.text($0.name, language: language) }.joined(separator: ", ")], language: language)
        }

        if !hasProAccess && player.energy == 0 {
            return L10n.text(AppContent.copy.feedback.emptyEnergy, language: language)
        }

        return nil
    }

    func buyTool(_ tool: ToolItem) {
        guard !ownsTool(tool.id) else { return }
        guard player.level >= tool.requiredLevel else {
            alertMessage = L10n.format(AppContent.copy.format.unlockItem, ["level": "\(tool.requiredLevel)", "item": L10n.text(tool.name)])
            Haptics.warning()
            return
        }
        guard player.coins >= tool.cost else {
            alertMessage = L10n.format(AppContent.copy.format.earnCoins, ["item": L10n.text(tool.name)])
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
            presentStore(reason: "businessUpgrade")
            return
        }

        guard player.level >= upgrade.requiredLevel else {
            alertMessage = L10n.format(AppContent.copy.format.unlockItem, ["level": "\(upgrade.requiredLevel)", "item": L10n.text(upgrade.name)])
            Haptics.warning()
            return
        }

        guard player.coins >= upgrade.cost else {
            alertMessage = L10n.format(AppContent.copy.format.earnCoins, ["item": L10n.text(upgrade.name)])
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
        if ownsUpgrade("commercial-insurance"), job.category == .commercial {
            coinsAwarded = Int(Double(coinsAwarded) * 1.10)
        }
        if ownsUpgrade("business-owner-mode"), job.category == .business {
            coinsAwarded = Int(Double(coinsAwarded) * 1.10)
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
            message = AppContent.copy.feedback.perfect
        } else if repairCorrect {
            message = AppContent.copy.feedback.rework
        } else {
            message = AppContent.copy.feedback.failed
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

    private func unlockLearningCardsForProgress() {
        for card in learningCards {
            guard card.requiredLevel <= player.level else { continue }
            guard !card.isPremium || hasProAccess else { continue }
            guard !player.unlockedLearningCardIDs.contains(card.id) else { continue }
            player.unlockedLearningCardIDs.append(card.id)
        }
    }
}
