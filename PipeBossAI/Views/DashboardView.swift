import StoreKit
import SwiftUI

struct DashboardView: View {
    @ObservedObject var game: GameViewModel
    @Environment(\.locale) private var locale
    @Environment(\.requestReview) private var requestReview

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            PipeBackground()

            ScrollView {
                VStack(spacing: 20) {
                    HeroHeader(
                        title: AppContent.copy.dashboard.title,
                        subtitle: AppContent.copy.dashboard.subtitle,
                        icon: "gauge.with.dots.needle.67percent"
                    )

                    profileCard

                    LazyVGrid(columns: columns, spacing: 12) {
                        MetricTile(title: AppContent.copy.dashboard.xp, value: "\(game.player.xp)", icon: "bolt.fill", tint: AppTheme.orange)
                        MetricTile(title: AppContent.copy.dashboard.coins, value: "\(game.player.coins)", icon: "dollarsign.circle.fill", tint: AppTheme.amber)
                        MetricTile(title: AppContent.copy.dashboard.energy, value: game.hasProAccess ? AppContent.copy.unlimited : "\(game.player.energy)/\(game.player.maxEnergy)", icon: "battery.100percent", tint: AppTheme.blue)
                        MetricTile(title: AppContent.copy.dashboard.reputation, value: game.player.reputation.formatted(.number.locale(locale).precision(.fractionLength(1))), icon: "star.fill", tint: AppTheme.amber)
                    }

                    nextJobCard

                    dailyChallenge

                    NavigationLink { SkillsView(game: game) } label: {
                        LLabel(AppContent.copy.training.title, systemImage: "chart.bar.fill")
                    }.buttonStyle(SecondaryActionButtonStyle())

                    PracticeQueueSection(game: game)

                    if game.training.careerAttempts > 0 { proCard }

                    HStack(spacing: 12) {
                        NavigationLink {
                            LeaderboardView(game: game)
                        } label: {
                            LLabel(AppContent.copy.dashboard.leaderboard, systemImage: "trophy.fill")
                        }
                        .buttonStyle(SecondaryActionButtonStyle())

                        NavigationLink {
                            SettingsPrivacyView(game: game)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .accessibilityLabel(Text(LocalizedStringKey(AppContent.copy.dashboard.settings)))
                        }
                        .buttonStyle(PlainIconButtonStyle())
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(Text(LocalizedStringKey(AppContent.copy.appName)))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard game.training.shouldRequestReview() else { return }
            do { try await Task.sleep(for: .seconds(2)) } catch { return }
            guard game.training.shouldRequestReview(), !game.showPaywall else { return }
            game.recordReviewRequest()
            requestReview()
        }
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(AppTheme.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: game.player.name)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.ink)
                    LText(AppContent.copy.format.careerLevel, values: ["career": L10n.text(game.player.careerTitle, language: locale.identifier), "level": "\(game.player.level)"])
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                }

                Spacer()
                RatingStars(rating: game.player.reputation)
            }

            XPProgressBar(
                progress: game.player.xpProgress,
                label: AppContent.copy.dashboard.careerProgress
            )
        }
        .pipeCard()
    }

    @ViewBuilder
    private var nextJobCard: some View {
        if let job = game.nextRecommendedJob {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: AppContent.copy.dashboard.nextJob)

                HStack(alignment: .top, spacing: 12) {
                    IconBadge(icon: job.iconSystemName, tint: AppTheme.orange)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            LText(job.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.ink)
                            Spacer()
                            DifficultyBadge(difficulty: job.difficulty)
                        }

                        LText(job.customerComplaint)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                NavigationLink {
                    JobSimulationView(game: game, job: job)
                } label: {
                    LLabel(AppContent.copy.dashboard.startJob, systemImage: "arrow.right.circle.fill")
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .pipeCard()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                if game.player.energy == 0 && !game.hasProAccess {
                    LText(AppContent.copy.training.energySummary).foregroundStyle(AppTheme.muted)
                }
                NavigationLink { JobBoardView(game: game) } label: {
                    LLabel(AppContent.copy.jobs.title, systemImage: "list.bullet.clipboard")
                }.buttonStyle(SecondaryActionButtonStyle())
            }
        }
    }

    @ViewBuilder
    private var dailyChallenge: some View {
        if let job = game.dailyChallenge {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: AppContent.copy.training.daily)
                LText(job.title).font(.headline)
                LText(AppContent.copy.training.days, values: ["count": "\(game.training.streak())"])
                    .font(.subheadline).foregroundStyle(AppTheme.muted)
                if game.training.completedDaily() {
                    LLabel(AppContent.copy.training.dailyDone, systemImage: "checkmark.circle.fill").foregroundStyle(AppTheme.success)
                }
                NavigationLink {
                    PracticeSessionView(game: game, jobs: [job], mode: .daily)
                } label: {
                    LLabel(AppContent.copy.training.dailyStart, systemImage: "calendar.badge.clock")
                }.buttonStyle(SecondaryActionButtonStyle())
            }
        }
    }

    private var proCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                IconBadge(icon: "crown.fill", tint: AppTheme.amber)
                VStack(alignment: .leading, spacing: 4) {
                    LText(AppContent.copy.paywall.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    LText(AppContent.copy.dashboard.proPrompt)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                    LText(AppContent.copy.reviewProductList)
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            Button {
                game.presentStore(reason: "dashboard")
            } label: {
                LLabel(AppContent.copy.dashboard.proButton, systemImage: "sparkles")
            }
            .buttonStyle(SecondaryActionButtonStyle())
        }
        .pipeCard()
    }
}
