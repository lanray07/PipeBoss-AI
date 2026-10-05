import StoreKit
import SwiftUI

struct PaywallView: View {
    @ObservedObject var game: GameViewModel
    @ObservedObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    private var subscriptionProducts: [SubscriptionProduct] {
        AppContent.storeProducts.filter {
            $0.kind == .monthlySubscription || $0.kind == .yearlySubscription
        }
    }

    private var oneTimeProducts: [SubscriptionProduct] {
        AppContent.storeProducts.filter { $0.kind == .nonConsumable }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PipeBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        HeroHeader(
                            title: AppContent.copy.paywall.title,
                            subtitle: AppContent.copy.paywall.subtitle,
                            icon: "crown.fill"
                        )

                        storeStatusCard

                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: AppContent.copy.paywall.subscriptions)
                            LText(AppContent.copy.paywall.sameAccess)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.muted)
                            if let savings = purchaseManager.annualSavingsPercent {
                                LLabel(AppContent.copy.format.annualSavings, systemImage: "tag.fill", values: ["percent": "\(savings)"])
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.success)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            ForEach(subscriptionProducts) { product in
                                PaywallProductRow(
                                    product: product,
                                    storeProduct: purchaseManager.product(for: product),
                                    owned: game.hasEntitlement(product.productID),
                                    purchaseManager: purchaseManager
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: AppContent.copy.paywall.oneTimePacks)
                            ForEach(oneTimeProducts) { product in
                                PackStoreRow(
                                    product: product,
                                    game: game,
                                    purchaseManager: purchaseManager
                                )
                            }
                        }

                        benefitsCard
                        termsCard

                        VStack(spacing: 10) {
                            Button {
                                Task { @MainActor in await purchaseManager.restorePurchases() }
                            } label: {
                                LLabel(AppContent.copy.paywall.restore, systemImage: "arrow.clockwise.circle.fill")
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                            .disabled(purchaseManager.isRestoring || purchaseManager.isPurchasing)

                            Button {
                                Task { @MainActor in await purchaseManager.manageSubscriptions() }
                            } label: {
                                LLabel(AppContent.copy.paywall.manage, systemImage: "person.crop.circle.badge.gearshape")
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }
                    }
                    .sectionSpacing()
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(Text(LocalizedStringKey(AppContent.copy.paywall.title)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(LocalizedStringKey(AppContent.copy.paywall.close)) {
                        dismiss()
                    }
                }
            }
            .alert(LocalizedStringKey(AppContent.copy.appName), isPresented: purchaseAlertBinding) {
                Button(LocalizedStringKey(AppContent.copy.ok), role: .cancel) {
                    purchaseManager.errorMessage = nil
                }
            } message: {
                LText(purchaseManager.errorMessage ?? "")
            }
            .task {
                if purchaseManager.products.isEmpty {
                    await purchaseManager.loadProducts()
                }
            }
        }
    }

    private var purchaseAlertBinding: Binding<Bool> {
        Binding(
            get: { purchaseManager.errorMessage != nil },
            set: { isPresented in
                if !isPresented { purchaseManager.errorMessage = nil }
            }
        )
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: AppContent.copy.proName)
            ForEach(subscriptionProducts.flatMap(\.benefits).uniqued(), id: \.self) { benefit in
                LLabel(benefit, systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .pipeCard()
    }

    @ViewBuilder
    private var storeStatusCard: some View {
        if purchaseManager.isLoading || purchaseManager.productLoadMessage != nil {
            VStack(alignment: .leading, spacing: 12) {
                if purchaseManager.isLoading {
                    LLabel(AppContent.copy.paywall.loadingProducts, systemImage: "hourglass")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.blue)
                } else if let message = purchaseManager.productLoadMessage {
                    LLabel(message, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.danger)

                    Button {
                        Task { @MainActor in await purchaseManager.loadProducts() }
                    } label: {
                        LLabel(AppContent.copy.paywall.retryStore, systemImage: "arrow.clockwise.circle.fill")
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            }
            .pipeCard()
        }
    }

    private var termsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            LText(AppContent.copy.paywall.termsSummary)
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            LText(AppContent.copy.paywall.reviewHint)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppTheme.blue)
                .fixedSize(horizontal: false, vertical: true)

            LText(AppContent.copy.educationalDisclaimer)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppTheme.danger)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                legalLink(AppContent.copy.paywall.terms, urlString: AppContent.copy.termsURL)
                legalLink(AppContent.copy.paywall.privacy, urlString: AppContent.copy.privacyURL)
            }
        }
        .pipeCard()
    }

    private func legalLink(_ title: String, urlString: String) -> some View {
        Link(destination: URL(string: urlString)!) {
            LLabel(title, systemImage: "doc.text.fill")
        }
        .font(.footnote.bold())
        .foregroundStyle(AppTheme.blue)
    }
}

private struct PaywallProductRow: View {
    let product: SubscriptionProduct
    let storeProduct: Product?
    let owned: Bool
    @ObservedObject var purchaseManager: PurchaseManager
    @State private var eligibleTrial: Product.SubscriptionOffer?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(icon: product.kind == .yearlySubscription ? "calendar.badge.checkmark" : "calendar", tint: AppTheme.amber)

                VStack(alignment: .leading, spacing: 5) {
                    LText(product.displayName)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    LText(product.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            ForEach(product.benefits.prefix(3), id: \.self) { benefit in
                LLabel(benefit, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Group {
                if let storeProduct {
                    LText(
                        product.kind == .yearlySubscription ? AppContent.copy.format.yearPrice : AppContent.copy.format.monthPrice,
                        values: ["price": storeProduct.displayPrice]
                    )
                } else {
                    LText(AppContent.copy.paywall.priceUnavailable)
                }
            }
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.blue)
                .fixedSize(horizontal: false, vertical: true)

            if owned {
                LLabel(AppContent.copy.paywall.active, systemImage: "checkmark.seal.fill")
                    .foregroundStyle(AppTheme.success)
            } else if purchaseManager.purchasedProductIDs.contains(AppContent.ProductIDs.proMonthly)
                        || purchaseManager.purchasedProductIDs.contains(AppContent.ProductIDs.proYearly) {
                Button {
                    Task { @MainActor in await purchaseManager.manageSubscriptions() }
                } label: {
                    LLabel(AppContent.copy.paywall.switchPlan, systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(SecondaryActionButtonStyle())
            } else if let storeProduct {
                if let trial = eligibleTrial {
                    LText(AppContent.copy.packs.trial, values: ["count": "\(trial.period.value)", "unit": L10n.text(trialUnit(trial.period.unit)), "price": storeProduct.displayPrice])
                        .font(.subheadline.weight(.semibold)).foregroundStyle(AppTheme.blue)
                }
                Button {
                    Task { @MainActor in
                        await purchaseManager.purchase(storeProduct)
                    }
                } label: {
                    LLabel(storeProduct.displayPrice, systemImage: "crown.fill")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .disabled(purchaseManager.isPurchasing)
            } else {
                unavailableProductState
            }
        }
        .pipeCard()
        .task(id: storeProduct?.id) {
            eligibleTrial = nil
            guard !owned, let info = storeProduct?.subscription,
                  let offer = info.introductoryOffer, offer.paymentMode == .freeTrial else { return }
            if await info.isEligibleForIntroOffer { eligibleTrial = offer }
        }
    }

    private func trialUnit(_ unit: Product.SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day: return AppContent.copy.packs.day
        case .week: return AppContent.copy.packs.week
        case .month: return AppContent.copy.packs.month
        case .year: return AppContent.copy.packs.year
        @unknown default: return AppContent.copy.packs.day
        }
    }

    @ViewBuilder
    private var unavailableProductState: some View {
        if purchaseManager.isLoading {
            LockRibbon(text: AppContent.copy.paywall.loadingProducts)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                LockRibbon(text: AppContent.copy.paywall.productUnavailable)
                Button {
                    Task { @MainActor in await purchaseManager.loadProducts() }
                } label: {
                    LLabel(AppContent.copy.paywall.retryStore, systemImage: "arrow.clockwise.circle.fill")
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
        }
    }
}


struct SettingsPrivacyView: View {
    @ObservedObject var game: GameViewModel
    @EnvironmentObject private var localization: LocalizationPreferences
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            PipeBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HeroHeader(
                        title: AppContent.copy.settings.title,
                        subtitle: AppContent.copy.settings.subtitle,
                        icon: "gearshape.fill"
                    )

                    Picker(LocalizedStringKey(AppContent.copy.settings.language), selection: $localization.selection) {
                        ForEach(localization.languages) { language in
                            LText(language.name).tag(language.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .pipeCard()

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: AppContent.copy.settings.privacy)
                        LText(AppContent.copy.privacySummary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                        LLabel(AppContent.copy.settings.localProgress, systemImage: "internaldrive.fill")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .pipeCard()

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: AppContent.copy.settings.disclaimer)
                        LText(AppContent.copy.educationalDisclaimer)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.danger)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .pipeCard()

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: AppContent.copy.settings.legal)
                        Link(destination: URL(string: AppContent.copy.termsURL)!) {
                            LLabel(AppContent.copy.paywall.terms, systemImage: "doc.text.fill")
                        }
                        Link(destination: URL(string: AppContent.copy.privacyURL)!) {
                            LLabel(AppContent.copy.paywall.privacy, systemImage: "hand.raised.fill")
                        }
                        LText(AppContent.copy.settings.appVersion, values: ["version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"])
                            .font(.footnote)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.blue)
                    .pipeCard()

                    LocalUsageView(game: game)

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        LLabel(AppContent.copy.settings.reset, systemImage: "trash.fill")
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(Text(LocalizedStringKey(AppContent.copy.settings.title)))
        .navigationBarTitleDisplayMode(.inline)
        .alert(LocalizedStringKey(AppContent.copy.settings.resetConfirm), isPresented: $showResetConfirmation) {
            Button(LocalizedStringKey(AppContent.copy.settings.cancel), role: .cancel) {}
            Button(LocalizedStringKey(AppContent.copy.settings.resetNow), role: .destructive) {
                game.resetProgress()
            }
        } message: {
            LText(AppContent.copy.settings.resetConfirmMessage)
        }
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
