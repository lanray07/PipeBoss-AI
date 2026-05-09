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
        .navigationTitle(AppContent.copy.inventory.title)
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
                        Text(tool.name)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        Text(tool.summary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }

                HStack(spacing: 10) {
                    Label("+\(tool.performanceBoost)", systemImage: "speedometer")
                    Label("Level \(tool.requiredLevel)", systemImage: "lock.open.fill")
                    if tool.isStarterTool {
                        Label(AppContent.copy.inventory.starter, systemImage: "checkmark.seal.fill")
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
                        Label("\(AppContent.copy.inventory.buy) - \(tool.cost)", systemImage: "cart.fill")
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

                    rewardedAdsCard

                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: AppContent.copy.business.upgrades)
                        ForEach(game.upgrades) { upgrade in
                            UpgradeCard(upgrade: upgrade, game: game)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: AppContent.copy.business.packs)
                        ForEach(oneTimeProducts) { product in
                            ProductPackCard(product: product, purchaseManager: purchaseManager, game: game)
                        }
                    }
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(AppContent.copy.business.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var rewardedAdsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(
                title: AppContent.copy.business.rewardedAds,
                subtitle: game.hasProAccess ? AppContent.copy.paywall.proAdsSummary : AppContent.copy.paywall.optionalAdsSummary
            )

            if game.hasProAccess {
                Label(AppContent.copy.proName, systemImage: "crown.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.amber)
            } else {
                HStack(spacing: 10) {
                    rewardedButton(AppContent.copy.business.coinsReward, icon: "dollarsign.circle.fill", reward: .coins)
                    rewardedButton(AppContent.copy.business.energyReward, icon: "battery.100percent", reward: .energy)
                }
                rewardedButton(AppContent.copy.business.hintReward, icon: "lightbulb.fill", reward: .hint)
            }
        }
        .pipeCard()
    }

    private func rewardedButton(_ title: String, icon: String, reward: RewardedAdReward) -> some View {
        Button {
            game.claimRewardedAdReward(reward)
        } label: {
            Label(title, systemImage: icon)
        }
        .buttonStyle(SecondaryActionButtonStyle())
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
                        Text(upgrade.name)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        Text(upgrade.summary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    if upgrade.isPremium {
                        DifficultyBadge(difficulty: .commercial)
                    }
                }

                Text(upgrade.effectDescription)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.blue)

                HStack(spacing: 10) {
                    Label("\(upgrade.cost)", systemImage: "dollarsign.circle.fill")
                    Label("Level \(upgrade.requiredLevel)", systemImage: "lock.open.fill")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)

                if game.ownsUpgrade(upgrade.id) {
                    LockRibbon(text: AppContent.copy.business.owned)
                } else {
                    Button {
                        game.buyUpgrade(upgrade)
                    } label: {
                        Label(AppContent.copy.business.buy, systemImage: "cart.fill")
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            }
        }
        .pipeCard()
    }
}

private struct ProductPackCard: View {
    let product: SubscriptionProduct
    @ObservedObject var purchaseManager: PurchaseManager
    @ObservedObject var game: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(icon: "shippingbox.fill", tint: AppTheme.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text(product.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            ForEach(product.benefits, id: \.self) { benefit in
                Label(benefit, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            if game.hasEntitlement(product.productID) {
                LockRibbon(text: AppContent.copy.business.owned)
            } else {
                Button {
                    Task { @MainActor in
                        if let storeProduct = purchaseManager.products.first(where: { $0.id == product.productID }) {
                            await purchaseManager.purchase(storeProduct)
                        } else {
                            game.alertMessage = AppContent.copy.paywall.storeUnavailableMessage
                        }
                    }
                } label: {
                    Label(product.pricePlaceholder, systemImage: "cart.fill")
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
        }
        .pipeCard()
    }
}
