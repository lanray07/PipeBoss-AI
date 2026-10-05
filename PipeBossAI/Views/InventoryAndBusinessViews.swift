import StoreKit
import SwiftUI

struct ToolInventoryView: View {
    @ObservedObject var game: GameViewModel

    var body: some View {
        ZStack {
            PipeBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HeroHeader(
                        title: AppContent.copy.inventory.title,
                        subtitle: AppContent.copy.inventory.subtitle,
                        icon: "wrench.and.screwdriver.fill"
                    )

                    ForEach(ToolCategory.allCases) { category in
                        let categoryTools = game.tools.filter { $0.category == category }
                        if !categoryTools.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionTitle(title: AppContent.copy.toolCategoryTitle(category))
                                ForEach(categoryTools) { tool in
                                    ToolInventoryCard(tool: tool, game: game)
                                }
                            }
                        }
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(Text(LocalizedStringKey(AppContent.copy.inventory.title)))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ToolInventoryCard: View {
    let tool: ToolItem
    @ObservedObject var game: GameViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(icon: tool.iconSystemName, tint: game.ownsTool(tool.id) ? AppTheme.blue : AppTheme.orange)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        LText(tool.name)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        LText(tool.summary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }

                HStack(spacing: 10) {
                    LLabel("+\(tool.performanceBoost)", systemImage: "speedometer")
                    LLabel(AppContent.copy.format.level, systemImage: "lock.open.fill", values: ["level": "\(tool.requiredLevel)"])
                    if tool.isStarterTool {
                        LLabel(AppContent.copy.inventory.starter, systemImage: "checkmark.seal.fill")
                    }
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)

                if game.ownsTool(tool.id) {
                    LockRibbon(text: AppContent.copy.inventory.owned)
                } else {
                    Button {
                        game.buyTool(tool)
                    } label: {
                        LLabel(AppContent.copy.format.buyCoins, systemImage: "cart.fill", values: ["coins": "\(tool.cost)"])
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            }
        }
        .pipeCard()
    }
}

struct BusinessUpgradeView: View {
    @ObservedObject var game: GameViewModel
    @ObservedObject var purchaseManager: PurchaseManager

    private var oneTimeProducts: [SubscriptionProduct] {
        AppContent.storeProducts.filter { $0.kind == .nonConsumable }
    }

    var body: some View {
        ZStack {
            PipeBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HeroHeader(
                        title: AppContent.copy.business.title,
                        subtitle: AppContent.copy.business.subtitle,
                        icon: "briefcase.fill"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: AppContent.copy.business.upgrades)
                        ForEach(game.upgrades) { upgrade in
                            UpgradeCard(upgrade: upgrade, game: game)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: AppContent.copy.business.packs)
                        ForEach(oneTimeProducts) { product in
                            PackStoreRow(
                                product: product,
                                game: game,
                                purchaseManager: purchaseManager
                            )
                        }
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(Text(LocalizedStringKey(AppContent.copy.business.title)))
        .navigationBarTitleDisplayMode(.inline)
    }

}

private struct UpgradeCard: View {
    let upgrade: Upgrade
    @ObservedObject var game: GameViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(icon: upgrade.iconSystemName, tint: upgrade.isPremium ? AppTheme.amber : AppTheme.blue)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        LText(upgrade.name)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        LText(upgrade.summary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    if upgrade.isPremium {
                        DifficultyBadge(difficulty: .commercial)
                    }
                }

                LText(upgrade.effectDescription)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.blue)

                HStack(spacing: 10) {
                    LLabel("\(upgrade.cost)", systemImage: "dollarsign.circle.fill")
                    LLabel(AppContent.copy.format.level, systemImage: "lock.open.fill", values: ["level": "\(upgrade.requiredLevel)"])
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)

                if game.ownsUpgrade(upgrade.id) {
                    LockRibbon(text: AppContent.copy.business.owned)
                } else {
                    Button {
                        game.buyUpgrade(upgrade)
                    } label: {
                        LLabel(AppContent.copy.business.buy, systemImage: "cart.fill")
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            }
        }
        .pipeCard()
    }
}
