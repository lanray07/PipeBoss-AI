import SwiftUI

struct LearningCardsView: View {
    @ObservedObject var game: GameViewModel

    var body: some View {
        ZStack {
            PipeBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HeroHeader(
                        title: AppContent.copy.learning.title,
                        subtitle: AppContent.copy.learning.subtitle,
                        icon: "book.pages.fill"
                    )

                    NavigationLink { SkillsView(game: game) } label: {
                        LLabel(AppContent.copy.training.title, systemImage: "chart.bar.fill")
                    }.buttonStyle(SecondaryActionButtonStyle())
                    PracticeQueueSection(game: game)

                    LazyVStack(spacing: 14) {
                        ForEach(game.learningCards) { card in
                            LearningCardRow(
                                card: card,
                                unlocked: game.player.unlockedLearningCardIDs.contains(card.id) && (!card.isPremium || game.hasProAccess),
                                proUnlocked: game.hasProAccess
                            )
                        }
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(Text(LocalizedStringKey(AppContent.copy.learning.title)))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LearningCardRow: View {
    let card: LearningCard
    let unlocked: Bool
    let proUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(icon: card.iconSystemName, tint: unlocked ? AppTheme.blue : AppTheme.muted)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        LText(card.title)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        if card.isPremium {
                            LockRibbon(text: AppContent.copy.learning.premium)
                        }
                    }

                    LText(card.topic)
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.orange)

                    LText(card.summary)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if unlocked {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(card.bulletPoints, id: \.self) { bullet in
                        LLabel(bullet, systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                if card.isPremium && !proUnlocked {
                    LockRibbon(text: AppContent.copy.learning.premium)
                } else {
                    LLabel(AppContent.copy.format.lockedLevel, systemImage: "lock.fill", values: ["level": "\(card.requiredLevel)"])
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.muted)
                }
            }
        }
        .pipeCard()
        .opacity(unlocked ? 1 : 0.72)
    }
}

struct LeaderboardView: View {
    @ObservedObject var game: GameViewModel

    private var milestones: [(String, Bool)] {
        let copy = AppContent.copy.training
        return [(copy.firstJob, game.training.careerAttempts >= 1 || !game.player.completedJobIDs.isEmpty),
                (copy.fiveJobs, game.training.careerAttempts >= 5),
                (copy.tenJobs, game.jobs.filter(\.isFreeStarterJob).allSatisfy { game.player.completedJobIDs.contains($0.id) }),
                (copy.firstPractice, game.training.attempts.contains { $0.mode != .career }),
                (copy.threeDays, game.training.learningDays.count >= 3)]
    }

    var body: some View {
        ZStack {
            PipeBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HeroHeader(
                        title: AppContent.copy.leaderboard.title,
                        subtitle: AppContent.copy.leaderboard.subtitle,
                        icon: "trophy.fill"
                    )

                    LazyVStack(spacing: 12) {
                        ForEach(Array(milestones.enumerated()), id: \.offset) { _, milestone in
                            HStack(spacing: 12) {
                                Image(systemName: milestone.1 ? "checkmark.seal.fill" : "seal")
                                    .foregroundStyle(milestone.1 ? AppTheme.success : AppTheme.muted)
                                LText(milestone.0).font(.headline)
                                Spacer()
                                LText(milestone.1 ? AppContent.copy.training.earned : AppContent.copy.training.keepGoing)
                                    .font(.caption).foregroundStyle(AppTheme.muted)
                            }.pipeCard()
                        }
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(Text(LocalizedStringKey(AppContent.copy.leaderboard.title)))
        .navigationBarTitleDisplayMode(.inline)
    }
}
