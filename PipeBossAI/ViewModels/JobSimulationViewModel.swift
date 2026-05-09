import Combine
import Foundation

@MainActor
final class JobSimulationViewModel: ObservableObject {
    enum Phase: Int, CaseIterable {
        case brief
        case inspect
        case diagnose
        case repair
        case result
    }

    let job: JobScenario

    @Published var phase: Phase = .brief
    @Published var selectedToolIDs = Set<String>()
    @Published var selectedDiagnosisID: String?
    @Published var selectedRepairID: String?
    @Published var diagnosisWasCorrect: Bool?
    @Published var outcome: JobOutcome?
    @Published var remainingSeconds: Int
    @Published var hintUnlocked = false

    private var timerTask: Task<Void, Never>?

    init(job: JobScenario) {
        self.job = job
        self.remainingSeconds = job.timeLimitMinutes * 60
    }

    deinit {
        timerTask?.cancel()
    }

    var progress: Double {
        Double(phase.rawValue + 1) / Double(Phase.allCases.count)
    }

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var allRequiredToolsSelected: Bool {
        Set(job.requiredTools).isSubset(of: selectedToolIDs)
    }

    var repairWasCorrect: Bool {
        selectedRepairID == job.correctRepairID
    }

    func startTimer() {
        guard timerTask == nil else { return }
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    guard let self, self.phase != .result, self.remainingSeconds > 0 else { return }
                    self.remainingSeconds -= 1
                }
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    func startInspection() {
        phase = .inspect
        Haptics.lightTap()
    }

    func toggleTool(_ toolID: String) {
        if selectedToolIDs.contains(toolID) {
            selectedToolIDs.remove(toolID)
        } else {
            selectedToolIDs.insert(toolID)
        }
        Haptics.lightTap()
    }

    func moveToDiagnosis() {
        guard allRequiredToolsSelected else {
            Haptics.warning()
            return
        }
        phase = .diagnose
    }

    func confirmDiagnosis() {
        guard let selectedDiagnosisID else {
            Haptics.warning()
            return
        }

        let isCorrect = selectedDiagnosisID == job.diagnosisQuestion.correctOptionID
        diagnosisWasCorrect = isCorrect
        isCorrect ? Haptics.success() : Haptics.error()
        phase = .repair
    }

    func confirmRepair(using game: GameViewModel) {
        guard selectedRepairID != nil else {
            Haptics.warning()
            return
        }

        let diagnosisCorrect = diagnosisWasCorrect ?? false
        let repairCorrect = repairWasCorrect
        outcome = game.completeJob(
            job,
            diagnosisCorrect: diagnosisCorrect,
            repairCorrect: repairCorrect,
            remainingSeconds: remainingSeconds
        )
        repairCorrect ? Haptics.success() : Haptics.error()
        phase = .result
        stopTimer()
    }

    func unlockHint(using game: GameViewModel) {
        if game.hasProAccess {
            hintUnlocked = true
            Haptics.success()
        } else {
            game.claimRewardedAdReward(.hint)
            hintUnlocked = true
        }
    }
}
