import StoreKit
import SwiftUI

struct PackStoreRow: View {
    let product: SubscriptionProduct
    @ObservedObject var game: GameViewModel
    @ObservedObject var purchaseManager: PurchaseManager

    private var includedJobs: [JobScenario] { PackContent.jobs(for: product.productID, in: game.jobs) }
    private var owned: Bool { game.hasEntitlement(product.productID) }
    private var toolsAlreadyOwned: Bool {
        product.productID == AppContent.ProductIDs.advancedTools && PackContent.specialistToolIDs.allSatisfy { game.ownsTool($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(icon: "shippingbox.fill", tint: AppTheme.orange)
                VStack(alignment: .leading, spacing: 4) {
                    LText(product.displayName).font(.headline)
                    LText(product.subtitle).font(.subheadline).foregroundStyle(AppTheme.muted)
                }
            }
            LText(product.productID == AppContent.ProductIDs.advancedTools ? AppContent.copy.packs.tools : AppContent.copy.packs.jobs,
                  values: ["count": "\(product.productID == AppContent.ProductIDs.advancedTools ? PackContent.specialistToolIDs.count : includedJobs.count)"])
                .font(.subheadline.weight(.semibold))
            NavigationLink {
                PackPreviewView(product: product, game: game)
            } label: {
                LLabel(owned ? AppContent.copy.packs.open : AppContent.copy.packs.preview, systemImage: owned ? "arrow.right.circle" : "eye")
            }.buttonStyle(SecondaryActionButtonStyle())
            if owned {
                LLabel(AppContent.copy.business.owned, systemImage: "checkmark.seal.fill").foregroundStyle(AppTheme.success)
            } else if toolsAlreadyOwned {
                LText(AppContent.copy.packs.toolOverlap).font(.footnote).foregroundStyle(AppTheme.muted)
            } else {
                if game.hasProAccess && product.productID != AppContent.ProductIDs.advancedTools {
                    LText(AppContent.copy.packs.proOverlap).font(.footnote).foregroundStyle(AppTheme.blue)
                }
                if let storeProduct = purchaseManager.product(for: product) {
                    LText(AppContent.copy.format.oneTimePrice, values: ["price": storeProduct.displayPrice])
                        .font(.subheadline.weight(.semibold))
                    Button {
                        Task { await purchaseManager.purchase(storeProduct) }
                    } label: {
                        LLabel(storeProduct.displayPrice, systemImage: "cart.fill")
                    }.buttonStyle(SecondaryActionButtonStyle()).disabled(purchaseManager.isPurchasing)
                } else {
                    LText(purchaseManager.isLoading ? AppContent.copy.paywall.loadingProducts : AppContent.copy.paywall.priceUnavailable)
                        .font(.footnote).foregroundStyle(AppTheme.muted)
                    if !purchaseManager.isLoading {
                        Button { Task { await purchaseManager.loadProducts() } } label: {
                            LLabel(AppContent.copy.paywall.retryStore, systemImage: "arrow.clockwise")
                        }.buttonStyle(SecondaryActionButtonStyle())
                    }
                }
            }
            LText(AppContent.copy.packs.permanent).font(.caption).foregroundStyle(AppTheme.muted)
        }.pipeCard()
    }
}

private struct PackPreviewView: View {
    let product: SubscriptionProduct
    @ObservedObject var game: GameViewModel
    @Environment(\.locale) private var locale
    private var includedJobs: [JobScenario] { PackContent.jobs(for: product.productID, in: game.jobs) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                LText(product.subtitle).font(.subheadline)
                if product.productID == AppContent.ProductIDs.advancedTools {
                    ForEach(game.tools.filter { PackContent.specialistToolIDs.contains($0.id) }) { tool in
                        VStack(alignment: .leading, spacing: 6) {
                            LLabel(tool.name, systemImage: tool.iconSystemName).font(.headline)
                            LText(tool.summary).font(.subheadline).foregroundStyle(AppTheme.muted)
                            if game.ownsTool(tool.id) {
                                LLabel(AppContent.copy.inventory.owned, systemImage: "checkmark.circle.fill").foregroundStyle(AppTheme.success)
                            }
                        }
                        Divider()
                    }
                    NavigationLink { ToolInventoryView(game: game) } label: {
                        LLabel(AppContent.copy.inventory.title, systemImage: "wrench.and.screwdriver")
                    }.buttonStyle(SecondaryActionButtonStyle())
                } else {
                    LText(AppContent.copy.packs.progression).font(.footnote).foregroundStyle(AppTheme.muted)
                    ForEach(includedJobs) { job in
                        VStack(alignment: .leading, spacing: 10) {
                            LLabel(job.title, systemImage: job.iconSystemName).font(.headline)
                            LText(job.customerComplaint).font(.subheadline).foregroundStyle(AppTheme.muted)
                            LText(AppContent.copy.format.level, values: ["level": "\(job.requiredLevel)"]).font(.caption.bold())
                            LText(AppContent.copy.format.needTools, values: ["tools": job.requiredTools.compactMap { game.tool(withID: $0)?.name }.map { L10n.text($0, language: locale.identifier) }.joined(separator: ", ")]).font(.caption)
                            if game.canStart(job) {
                                NavigationLink { JobSimulationView(game: game, job: job) } label: {
                                    LLabel(AppContent.copy.jobs.start, systemImage: "play.fill")
                                }.buttonStyle(PrimaryActionButtonStyle())
                            } else if let reason = game.lockReason(for: job, language: locale.identifier) {
                                LText(reason).font(.caption).foregroundStyle(AppTheme.muted)
                            }
                        }
                        Divider()
                    }
                    if product.productID == AppContent.ProductIDs.businessOwnerMode {
                        LText(AppContent.copy.packs.business).font(.footnote).foregroundStyle(AppTheme.blue)
                        ForEach(game.upgrades.filter(\.isPremium)) { upgrade in
                            LLabel(upgrade.name, systemImage: upgrade.iconSystemName).font(.subheadline)
                        }
                    }
                }
            }.sectionSpacing().padding(.vertical, 20)
        }.background(AppTheme.surface)
            .navigationTitle(Text(LocalizedStringKey(product.displayName)))
            .navigationBarTitleDisplayMode(.inline)
    }
}
