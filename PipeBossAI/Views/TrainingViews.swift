import SwiftUI

struct SkillsView: View {
    @ObservedObject var game: GameViewModel
    @Environment(\.locale) private var locale

    private var summary: TopicPerformance {
        TopicPerformance(category: .business, attempts: game.training.attempts)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionTitle(title: AppContent.copy.training.title, subtitle: AppContent.copy.training.subtitle)
                if game.training.attempts.isEmpty {
                    EmptyState(icon: "chart.bar.fill", title: AppContent.copy.training.empty, message: AppContent.copy.training.emptyDetail)
                } else {
                    AccuracyRow(performance: summary)
                    LText(AppContent.copy.training.attempts, values: ["count": "\(game.training.totalAttempts)"])
                        .font(.subheadline).foregroundStyle(AppTheme.muted)
                }
                PracticeQueueSection(game: game)
                if game.hasProAccess {
                    SectionTitle(title: AppContent.copy.training.topics)
                    ForEach(game.topicPerformance) { topic in
                        VStack(alignment: .leading, spacing: 10) {
                            LText(AppContent.copy.categoryTitle(topic.category)).font(.headline)
                            AccuracyRow(performance: topic)
                            LText(AppContent.copy.training.attempts, values: ["count": "\(topic.attempts.count)"])
                                .font(.caption).foregroundStyle(AppTheme.muted)
                        }
                        Divider()
                    }
                    NavigationLink {
                        PracticeSessionView(game: game, jobs: Array(game.jobs.filter { game.isJobUnlocked($0) }.shuffled().prefix(5)), mode: .exam)
                    } label: {
                        LLabel(AppContent.copy.training.examStart, systemImage: "checkmark.seal.fill")
                    }.buttonStyle(PrimaryActionButtonStyle())
                    LText(AppContent.copy.training.examSummary).font(.footnote).foregroundStyle(AppTheme.muted)
                    SectionTitle(title: AppContent.copy.training.history)
                    ForEach(Array(game.training.attempts.suffix(10).reversed())) { attempt in
                        if let job = game.jobs.first(where: { $0.id == attempt.jobID }) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    LText(job.title).font(.headline)
                                    Spacer()
                                    Image(systemName: attempt.correct ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                                        .foregroundStyle(attempt.correct ? AppTheme.success : AppTheme.orange)
                                }
                                Text(attempt.date, style: .date).font(.caption).foregroundStyle(AppTheme.muted)
                                LText(AppContent.copy.training.diagnosisChoice, values: ["choice": choice(attempt.diagnosisID, in: job.diagnosisQuestion.options)])
                                LText(AppContent.copy.training.repairChoice, values: ["choice": choice(attempt.repairID, in: job.repairOptions)])
                            }.font(.subheadline)
                            Divider()
                        }
                    }
                    ShareLink(item: report) {
                        LLabel(AppContent.copy.training.shareReport, systemImage: "square.and.arrow.up")
                    }.buttonStyle(SecondaryActionButtonStyle())
                } else {
                    LText(AppContent.copy.training.detailedPro).font(.subheadline).foregroundStyle(AppTheme.muted)
                    Button { game.presentStore(reason: "skills") } label: {
                        LLabel(AppContent.copy.training.explorePro, systemImage: "crown.fill")
                    }.buttonStyle(SecondaryActionButtonStyle())
                }
            }.sectionSpacing().padding(.vertical, 20)
        }
        .background(AppTheme.surface)
        .navigationTitle(Text(LocalizedStringKey(AppContent.copy.training.title)))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func choice(_ id: String, in options: [DecisionOption]) -> String {
        L10n.text(options.first { $0.id == id }?.title ?? AppContent.copy.training.empty, language: locale.identifier)
    }

    private var report: String {
        var lines = [L10n.text(AppContent.copy.training.report, language: locale.identifier),
                     L10n.format(AppContent.copy.training.reportSummary, ["count": "\(game.training.totalAttempts)"], language: locale.identifier)]
        for topic in game.topicPerformance {
            lines.append(L10n.text(AppContent.copy.categoryTitle(topic.category), language: locale.identifier))
            lines.append("\(L10n.text(AppContent.copy.training.diagnosis, language: locale.identifier)): \(topic.diagnosisAccuracy.formatted(.percent.locale(locale).precision(.fractionLength(0))))")
            lines.append("\(L10n.text(AppContent.copy.training.repair, language: locale.identifier)): \(topic.repairAccuracy.formatted(.percent.locale(locale).precision(.fractionLength(0))))")
        }
        lines.append(L10n.text(AppContent.copy.educationalDisclaimer, language: locale.identifier))
        return lines.joined(separator: "\n")
    }
}

private struct AccuracyRow: View {
    let performance: TopicPerformance
    @Environment(\.locale) private var locale
    var body: some View {
        VStack(spacing: 12) {
            metric(AppContent.copy.training.diagnosis, value: performance.diagnosisAccuracy, tint: AppTheme.blue)
            metric(AppContent.copy.training.repair, value: performance.repairAccuracy, tint: AppTheme.orange)
        }
    }
    private func metric(_ title: String, value: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                LText(title)
                Spacer()
                Text(value.formatted(.percent.locale(locale).precision(.fractionLength(0)))).monospacedDigit()
            }.font(.subheadline.weight(.semibold))
            ProgressView(value: value).tint(tint)
        }
    }
}

struct PracticeQueueSection: View {
    @ObservedObject var game: GameViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: AppContent.copy.training.practice)
            if game.practiceJobs.isEmpty {
                LText(AppContent.copy.training.caughtUp).font(.headline)
                LText(AppContent.copy.training.caughtUpDetail).font(.subheadline).foregroundStyle(AppTheme.muted)
            } else {
                LText(AppContent.copy.training.reviewCount, values: ["count": "\(game.practiceJobs.count)"])
                NavigationLink {
                    PracticeSessionView(game: game, jobs: Array(game.practiceJobs.prefix(5)), mode: .practice)
                } label: {
                    LLabel(AppContent.copy.training.practiceStart, systemImage: "arrow.triangle.2.circlepath")
                }.buttonStyle(SecondaryActionButtonStyle())
            }
            LText(AppContent.copy.training.practiceSummary).font(.footnote).foregroundStyle(AppTheme.muted)
        }
    }
}

struct PracticeSessionView: View {
    @ObservedObject var game: GameViewModel
    @State private var jobs: [JobScenario]
    let mode: TrainingMode
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0
    @State private var diagnosisID: String?
    @State private var repairID: String?
    @State private var choosingRepair = false
    @State private var answers: [TrainingAttempt] = []

    init(game: GameViewModel, jobs: [JobScenario], mode: TrainingMode) {
        self.game = game
        self.mode = mode
        _jobs = State(initialValue: jobs)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if index < jobs.count {
                    question(jobs[index])
                } else {
                    results
                }
            }.sectionSpacing().padding(.vertical, 20)
        }
        .background(AppTheme.surface)
        .navigationTitle(Text(LocalizedStringKey(mode == .exam ? AppContent.copy.training.exam : AppContent.copy.training.practice)))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func question(_ job: JobScenario) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            LText(AppContent.copy.training.question, values: ["number": "\(index + 1)", "count": "\(jobs.count)"]).font(.caption.bold())
            ProgressView(value: Double(index), total: Double(max(1, jobs.count))).tint(AppTheme.orange)
            LText(job.title).font(.title3.bold())
            LText(job.customerComplaint).font(.subheadline)
            ForEach(job.symptoms, id: \.self) { symptom in
                LLabel(symptom, systemImage: "drop.circle").font(.subheadline).foregroundStyle(AppTheme.muted)
            }
            LLabel(job.safetyWarning, systemImage: "exclamationmark.triangle.fill").font(.footnote).foregroundStyle(AppTheme.danger)
            LText(choosingRepair ? AppContent.copy.simulation.repair : job.diagnosisQuestion.prompt).font(.headline)
            ForEach(choosingRepair ? job.repairOptions : job.diagnosisQuestion.options) { option in
                Button {
                    if choosingRepair { repairID = option.id } else { diagnosisID = option.id }
                    Haptics.lightTap()
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: (choosingRepair ? repairID : diagnosisID) == option.id ? "checkmark.circle.fill" : "circle")
                        LText(option.title).multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }.padding(14).frame(maxWidth: .infinity, alignment: .leading)
                }.buttonStyle(.bordered).tint(AppTheme.blue)
            }
            Button {
                if !choosingRepair {
                    choosingRepair = true
                } else if let diagnosisID, let repairID {
                    let attempt = TrainingAttempt(job: job, diagnosisID: diagnosisID, repairID: repairID, mode: mode)
                    answers.append(attempt)
                    game.recordTraining(job: job, diagnosisID: diagnosisID, repairID: repairID, mode: mode)
                    index += 1
                    self.diagnosisID = nil
                    self.repairID = nil
                    choosingRepair = false
                    if index == jobs.count { Haptics.success() }
                }
            } label: {
                LLabel(choosingRepair ? AppContent.copy.training.next : AppContent.copy.simulation.continueDiagnosis, systemImage: "arrow.right.circle.fill")
            }.buttonStyle(PrimaryActionButtonStyle())
                .disabled(choosingRepair ? repairID == nil : diagnosisID == nil)
        }
    }

    private var results: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: AppContent.copy.training.assessmentResult)
            LText(AppContent.copy.training.score, values: ["correct": "\(answers.filter(\.diagnosisCorrect).count + answers.filter(\.repairCorrect).count)", "count": "\(answers.count * 2)"]).font(.headline)
            ForEach(answers) { attempt in
                if let job = jobs.first(where: { $0.id == attempt.jobID }) {
                    VStack(alignment: .leading, spacing: 10) {
                        LLabel(job.title, systemImage: attempt.correct ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath").font(.headline)
                        LText(job.diagnosisQuestion.explanation)
                        if let repair = job.repairOptions.first(where: { $0.id == job.correctRepairID }) {
                            LLabel(repair.title, systemImage: "wrench.and.screwdriver")
                            LText(repair.detail)
                        }
                        LText(job.learningTip).foregroundStyle(AppTheme.blue)
                    }.font(.subheadline).pipeCard()
                }
            }
            Button { dismiss() } label: {
                LLabel(AppContent.copy.training.finish, systemImage: "checkmark")
            }.buttonStyle(PrimaryActionButtonStyle())
        }
    }
}
