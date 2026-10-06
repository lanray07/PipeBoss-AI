import SwiftUI

struct JobBoardView: View {
    @ObservedObject var game: GameViewModel
    @Environment(\.locale) private var locale
    @State private var selectedDifficulty: JobDifficulty?
    @State private var activeJob: JobScenario?

    private var filteredJobs: [JobScenario] {
        guard let selectedDifficulty else { return game.jobs }
        return game.jobs.filter { $0.difficulty == selectedDifficulty }
    }

    var body: some View {
        ZStack {
            PipeBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HeroHeader(
                        title: AppContent.copy.jobs.title,
                        subtitle: AppContent.copy.jobs.subtitle,
                        icon: "list.bullet.clipboard.fill"
                    )

                    filterBar

                    if !game.hasProAccess && game.player.energy == 0 {
                        LText(AppContent.copy.training.energySummary).font(.subheadline).foregroundStyle(AppTheme.muted)
                        NavigationLink { SkillsView(game: game) } label: {
                            LLabel(AppContent.copy.training.practiceStart, systemImage: "arrow.triangle.2.circlepath")
                        }.buttonStyle(SecondaryActionButtonStyle())
                    }

                    LazyVStack(spacing: 14) {
                        ForEach(filteredJobs) { job in
                            Button {
                                open(job)
                            } label: {
                                JobBoardCard(
                                    job: job,
                                    requiredToolNames: job.requiredTools.compactMap { game.tool(withID: $0)?.name }.map { L10n.text($0, language: locale.identifier) },
                                    lockReason: game.lockReason(for: job, language: locale.identifier),
                                    completed: game.player.completedJobIDs.contains(job.id)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(Text(LocalizedStringKey(AppContent.copy.jobs.title)))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $activeJob) { job in
            JobSimulationView(game: game, job: job)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterButton(title: AppContent.copy.jobs.allFilter, difficulty: nil)
                ForEach(JobDifficulty.allCases) { difficulty in
                    filterButton(title: AppContent.copy.difficultyTitle(difficulty), difficulty: difficulty)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private func filterButton(title: String, difficulty: JobDifficulty?) -> some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                selectedDifficulty = difficulty
            }
        } label: {
            LText(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selectedDifficulty == difficulty ? .white : AppTheme.navy)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(selectedDifficulty == difficulty ? AppTheme.blue : AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppTheme.line, lineWidth: 1)
                }
        }
    }

    private func open(_ job: JobScenario) {
        if game.canStart(job) {
            activeJob = job
            return
        }

        if !game.hasContentAccess(to: job) {
            game.presentStore(reason: "lockedJob")
        } else {
            game.alertMessage = game.lockReason(for: job, language: locale.identifier)
        }
    }
}

private struct JobBoardCard: View {
    let job: JobScenario
    let requiredToolNames: [String]
    let lockReason: String?
    let completed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(icon: job.iconSystemName, tint: lockReason == nil ? AppTheme.blue : AppTheme.muted)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        LText(job.title)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 12)
                        DifficultyBadge(difficulty: job.difficulty)
                    }

                    LText(job.customerComplaint)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                LLabel("\(job.timeLimitMinutes)m", systemImage: "timer")
                LLabel("\(job.rewardCoins)", systemImage: "dollarsign.circle")
                LLabel("\(job.rewardXP) XP", systemImage: "bolt.fill")
                if completed {
                    LLabel(AppContent.copy.simulation.correct, systemImage: "checkmark.seal.fill")
                        .foregroundStyle(AppTheme.success)
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.muted)

            VStack(alignment: .leading, spacing: 6) {
                LText(AppContent.copy.jobs.requiredTools)
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.ink)
                LText(requiredToolNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let lockReason {
                LockRibbon(text: lockReason)
            }
        }
        .pipeCard()
        .opacity(lockReason == nil ? 1 : 0.72)
    }
}
