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

                    LazyVStack(spacing: 14) {
                        ForEach(game.learningCards) { card in
                            LearningCardRow(
                                card: card,
                                unlocked: game.player.unlockedLearningCardIDs.contains(card.id),
                                proUnlocked: game.hasProAccess
                            )
                        }
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(AppContent.copy.learning.title)
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
                        Text(card.title)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        if card.isPremium {
                            LockRibbon(text: AppContent.copy.learning.premium)
                        }
                    }

                    Text(card.topic)
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.orange)

                    Text(card.summary)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if unlocked {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(card.bulletPoints, id: \.self) { bullet in
                        Label(bullet, systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                LockRibbon(text: card.isPremium && !proUnlocked ? AppContent.copy.learning.premium : "\(AppContent.copy.learning.locked) - Level \(card.requiredLevel)")
            }
        }
        .pipeCard()
        .opacity(unlocked ? 1 : 0.72)
    }
}

struct LeaderboardView: View {
    @ObservedObject var game: GameViewModel

    private var entries: [LeaderboardEntry] {
        var list = AppContent.leaderboard.filter { $0.name != "You" }
        list.append(
            LeaderboardEntry(
                id: "player",
                rank: max(1, 10 - min(game.player.level, 9)),
                name: game.player.name,
                level: game.player.level,
                reputation: game.player.reputation,
                badge: game.player.careerTitle
            )
        )
        return list.sorted { lhs, rhs in
            if lhs.level == rhs.level {
                return lhs.reputation > rhs.reputation
            }
            return lhs.level > rhs.level
        }
        .enumerated()
        .map { index, entry in
            LeaderboardEntry(id: entry.id, rank: index + 1, name: entry.name, level: entry.level, reputation: entry.reputation, badge: entry.badge)
        }
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
                        ForEach(entries) { entry in
                            LeaderboardRow(entry: entry, isPlayer: entry.id == "player")
                        }
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(AppContent.copy.leaderboard.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isPlayer: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text("#\(entry.rank)")
                .font(.headline.bold())
                .foregroundStyle(isPlayer ? AppTheme.orange : AppTheme.blue)
                .frame(width: 48, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text(entry.badge)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Level \(entry.level)")
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.ink)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                    Text(String(format: "%.1f", entry.reputation))
                }
                .font(.caption.bold())
                .foregroundStyle(AppTheme.amber)
            }
        }
        .pipeCard()
        .overlay(alignment: .topTrailing) {
            if isPlayer {
                Text(AppContent.copy.dashboard.reputation)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AppTheme.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(8)
            }
        }
    }
}
