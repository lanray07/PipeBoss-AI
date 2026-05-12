import SwiftUI

struct DashboardView: View {
    @ObservedObject var game: GameViewModel

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
                        MetricTile(title: AppContent.copy.dashboard.energy, value: game.hasProAccess ? "Unlimited" : "\(game.player.energy)/\(game.player.maxEnergy)", icon: "battery.100percent", tint: AppTheme.blue)
                        MetricTile(title: AppContent.copy.dashboard.reputation, value: String(format: "%.1f", game.player.reputation), icon: "star.fill", tint: AppTheme.amber)
                    }

                    nextJobCard

                    proCard

                    HStack(spacing: 12) {
                        NavigationLink {
                            LeaderboardView(game: game)
                        } label: {
                            Label(AppContent.copy.dashboard.leaderboard, systemImage: "trophy.fill")
                        }
                        .buttonStyle(SecondaryActionButtonStyle())

                        NavigationLink {
                            SettingsPrivacyView(game: game)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .accessibilityLabel(AppContent.copy.dashboard.settings)
                        }
                        .buttonStyle(PlainIconButtonStyle())
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(AppContent.copy.appName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(AppTheme.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(game.player.name)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.ink)
                    Text("\(game.player.careerTitle) - Level \(game.player.level)")
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
                            Text(job.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.ink)
                            Spacer()
                            DifficultyBadge(difficulty: job.difficulty)
                        }

                        Text(job.customerComplaint)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                NavigationLink {
                    JobBoardView(game: game)
                } label: {
                    Label(AppContent.copy.dashboard.startJob, systemImage: "arrow.right.circle.fill")
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .pipeCard()
        } else {
            EmptyState(
                icon: "lock.open.fill",
                title: AppContent.copy.jobs.locked,
                message: AppContent.copy.jobs.subtitle
            )
        }
    }

    private var proCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                IconBadge(icon: "crown.fill", tint: AppTheme.amber)
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppContent.copy.paywall.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text(AppContent.copy.dashboard.proPrompt)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                    Text(AppContent.copy.reviewProductList)
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            Button {
                game.showPaywall = true
            } label: {
                Label(AppContent.copy.dashboard.proButton, systemImage: "sparkles")
            }
            .buttonStyle(SecondaryActionButtonStyle())
        }
        .pipeCard()
    }
}
