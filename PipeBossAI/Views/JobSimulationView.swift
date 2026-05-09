import SwiftUI

struct JobSimulationView: View {
    @ObservedObject var game: GameViewModel
    @StateObject private var viewModel: JobSimulationViewModel
    @Environment(\.dismiss) private var dismiss

    init(game: GameViewModel, job: JobScenario) {
        self.game = game
        _viewModel = StateObject(wrappedValue: JobSimulationViewModel(job: job))
    }

    var body: some View {
        ZStack {
            PipeBackground()

            ScrollView {
                VStack(spacing: 18) {
                    simulationHeader

                    switch viewModel.phase {
                    case .brief:
                        briefView
                    case .inspect:
                        inspectionView
                    case .diagnose:
                        diagnosisView
                    case .repair:
                        repairView
                    case .result:
                        resultView
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(viewModel.job.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }

    private var simulationHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DifficultyBadge(difficulty: viewModel.job.difficulty)
                Spacer()
                Label(viewModel.formattedTime, systemImage: "timer")
                    .font(.subheadline.bold())
                    .foregroundStyle(viewModel.remainingSeconds < 60 ? AppTheme.danger : AppTheme.navy)
            }

            ProgressView(value: viewModel.progress)
                .tint(AppTheme.orange)

            HStack {
                Text(AppContent.copy.simulation.customerBrief)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text(AppContent.copy.categoryTitle(viewModel.job.category))
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.blue)
            }
        }
        .pipeCard()
    }

    private var briefView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.job.customerComplaint)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            symptomList
            safetyWarning
            hintBox

            Button {
                viewModel.startInspection()
            } label: {
                Label(AppContent.copy.simulation.inspect, systemImage: "magnifyingglass")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .pipeCard()
    }

    private var inspectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(
                title: AppContent.copy.simulation.selectTools,
                subtitle: AppContent.copy.jobs.requiredTools
            )

            ForEach(viewModel.job.requiredTools, id: \.self) { toolID in
                if let tool = game.tool(withID: toolID) {
                    ToolSelectionRow(
                        tool: tool,
                        owned: game.ownsTool(toolID),
                        selected: viewModel.selectedToolIDs.contains(toolID)
                    ) {
                        guard game.ownsTool(toolID) else {
                            game.alertMessage = AppContent.copy.jobs.missingTools
                            Haptics.warning()
                            return
                        }
                        viewModel.toggleTool(toolID)
                    }
                }
            }

            Button {
                viewModel.moveToDiagnosis()
            } label: {
                Label(AppContent.copy.simulation.continueDiagnosis, systemImage: "questionmark.circle.fill")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(!viewModel.allRequiredToolsSelected)
            .opacity(viewModel.allRequiredToolsSelected ? 1 : 0.5)
        }
        .pipeCard()
    }

    private var diagnosisView: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: AppContent.copy.simulation.diagnosis)

            Text(viewModel.job.diagnosisQuestion.prompt)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(viewModel.job.diagnosisQuestion.options) { option in
                OptionRow(
                    option: option,
                    selected: viewModel.selectedDiagnosisID == option.id,
                    state: nil
                ) {
                    viewModel.selectedDiagnosisID = option.id
                    Haptics.lightTap()
                }
            }

            Button {
                viewModel.confirmDiagnosis()
            } label: {
                Label(AppContent.copy.simulation.confirmDiagnosis, systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(viewModel.selectedDiagnosisID == nil)
            .opacity(viewModel.selectedDiagnosisID == nil ? 0.5 : 1)
        }
        .pipeCard()
    }

    private var repairView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let diagnosisWasCorrect = viewModel.diagnosisWasCorrect {
                FeedbackBanner(
                    correct: diagnosisWasCorrect,
                    title: diagnosisWasCorrect ? AppContent.copy.simulation.correct : AppContent.copy.simulation.needsRework,
                    message: viewModel.job.diagnosisQuestion.explanation
                )
            }

            SectionTitle(title: AppContent.copy.simulation.repair)

            ForEach(viewModel.job.repairOptions) { option in
                OptionRow(
                    option: option,
                    selected: viewModel.selectedRepairID == option.id,
                    state: nil
                ) {
                    viewModel.selectedRepairID = option.id
                    Haptics.lightTap()
                }
            }

            Button {
                viewModel.confirmRepair(using: game)
            } label: {
                Label(AppContent.copy.simulation.confirmRepair, systemImage: "wrench.and.screwdriver.fill")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(viewModel.selectedRepairID == nil)
            .opacity(viewModel.selectedRepairID == nil ? 0.5 : 1)
        }
        .pipeCard()
    }

    @ViewBuilder
    private var resultView: some View {
        if let outcome = viewModel.outcome {
            ResultCard(outcome: outcome) {
                dismiss()
            }
        }
    }

    private var symptomList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppContent.copy.simulation.symptoms)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            ForEach(viewModel.job.symptoms, id: \.self) { symptom in
                Label(symptom, systemImage: "drop.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var safetyWarning: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(AppContent.copy.simulation.safety, systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.danger)
            Text(viewModel.job.safetyWarning)
                .font(.subheadline)
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(AppTheme.danger.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var hintBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(AppContent.copy.simulation.mentorHint, systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(AppTheme.blue)

            if viewModel.hintUnlocked {
                Text(viewModel.job.mentorHint)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Button {
                    viewModel.unlockHint(using: game)
                } label: {
                    Label(AppContent.copy.simulation.unlockHint, systemImage: game.hasProAccess ? "lightbulb.fill" : "play.rectangle.fill")
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
        }
        .padding(12)
        .background(AppTheme.blue.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ToolSelectionRow: View {
    let tool: ToolItem
    let owned: Bool
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconBadge(icon: tool.iconSystemName, tint: owned ? AppTheme.blue : AppTheme.muted)
                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text(owned ? tool.summary : AppContent.copy.jobs.missingTools)
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? AppTheme.success : AppTheme.line)
            }
            .padding(12)
            .background(selected ? AppTheme.blue.opacity(0.08) : AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(selected ? AppTheme.blue.opacity(0.35) : AppTheme.line, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct OptionRow: View {
    enum OptionState {
        case correct
        case wrong
    }

    let option: DecisionOption
    let selected: Bool
    let state: OptionState?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(tint)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text(option.detail)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(12)
            .background(selected ? tint.opacity(0.08) : AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(selected ? tint.opacity(0.38) : AppTheme.line, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var tint: Color {
        switch state {
        case .correct:
            return AppTheme.success
        case .wrong:
            return AppTheme.danger
        case .none:
            return selected ? AppTheme.blue : AppTheme.muted
        }
    }

    private var iconName: String {
        switch state {
        case .correct:
            return "checkmark.circle.fill"
        case .wrong:
            return "xmark.circle.fill"
        case .none:
            return selected ? "largecircle.fill.circle" : "circle"
        }
    }
}

private struct FeedbackBanner: View {
    let correct: Bool
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: correct ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(correct ? AppTheme.success : AppTheme.danger)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background((correct ? AppTheme.success : AppTheme.danger).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ResultCard: View {
    let outcome: JobOutcome
    let finish: () -> Void
    @State private var pulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(spacing: 12) {
                Image(systemName: outcome.repairCorrect ? "checkmark.seal.fill" : "arrow.triangle.2.circlepath.circle.fill")
                    .font(.system(size: 58, weight: .bold))
                    .foregroundStyle(outcome.repairCorrect ? AppTheme.success : AppTheme.orange)
                    .scaleEffect(pulse ? 1.05 : 0.95)
                    .animation(.spring(response: 0.45, dampingFraction: 0.62).repeatCount(2, autoreverses: true), value: pulse)

                Text(outcome.jobTitle)
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)

                Text(outcome.message)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 12) {
                ResultMetricTile(title: AppContent.copy.dashboard.xp, value: "+\(outcome.xpAwarded)", icon: "bolt.fill", tint: AppTheme.orange)
                ResultMetricTile(title: AppContent.copy.dashboard.coins, value: "+\(outcome.coinsAwarded)", icon: "dollarsign.circle.fill", tint: AppTheme.amber)
            }

            StatRow(icon: "star.fill", title: AppContent.copy.dashboard.reputation, value: "\(String(format: "%.1f", outcome.rating)) rating")

            VStack(alignment: .leading, spacing: 8) {
                Label(AppContent.copy.simulation.masterTip, systemImage: "graduationcap.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.blue)
                Text(outcome.learningTip)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(AppTheme.blue.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Label(AppContent.copy.simulation.safety, systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.danger)
                Text(outcome.safetyWarning)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(AppTheme.danger.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Button(action: finish) {
                Label(AppContent.copy.simulation.finish, systemImage: "house.fill")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .pipeCard()
        .onAppear {
            pulse = true
        }
    }
}

private struct ResultMetricTile: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.ink)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tint.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
