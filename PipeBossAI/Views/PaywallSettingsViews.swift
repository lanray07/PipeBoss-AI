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

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(subscriptionProducts) { product in
                                PaywallProductRow(
                                    product: product,
                                    storeProduct: purchaseManager.products.first { $0.id == product.productID },
                                    owned: game.hasEntitlement(product.productID),
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
                                Label(AppContent.copy.paywall.restore, systemImage: "arrow.clockwise.circle.fill")
                            }
                            .buttonStyle(SecondaryActionButtonStyle())

                            Button {
                                Task { @MainActor in await purchaseManager.manageSubscriptions() }
                            } label: {
                                Label(AppContent.copy.paywall.manage, systemImage: "person.crop.circle.badge.gearshape")
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }
                    }
                    .sectionSpacing()
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(AppContent.copy.proName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(AppContent.copy.paywall.close) {
                        dismiss()
                    }
                }
            }
            .alert(AppContent.copy.appName, isPresented: purchaseAlertBinding) {
                Button(AppContent.copy.ok, role: .cancel) {
                    purchaseManager.errorMessage = nil
                }
            } message: {
                Text(purchaseManager.errorMessage ?? "")
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
                Label(benefit, systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .pipeCard()
    }

    private var termsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppContent.copy.paywall.termsSummary)
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            Text(AppContent.copy.educationalDisclaimer)
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
            Label(title, systemImage: "doc.text.fill")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(icon: product.kind == .yearlySubscription ? "calendar.badge.checkmark" : "calendar", tint: AppTheme.amber)

                VStack(alignment: .leading, spacing: 5) {
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

            ForEach(product.benefits.prefix(3), id: \.self) { benefit in
                Label(benefit, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            if owned {
                LockRibbon(text: AppContent.copy.business.owned)
            } else {
                Button {
                    Task { @MainActor in
                        if let storeProduct {
                            await purchaseManager.purchase(storeProduct)
                        } else {
                            purchaseManager.errorMessage = AppContent.copy.paywall.storeUnavailableMessage
                        }
                    }
                } label: {
                    Label(storeProduct?.displayPrice ?? product.pricePlaceholder, systemImage: "crown.fill")
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
        .pipeCard()
    }
}

struct SettingsPrivacyView: View {
    @ObservedObject var game: GameViewModel
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

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: AppContent.copy.settings.privacy)
                        Text(AppContent.copy.privacySummary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                        Label(AppContent.copy.settings.localProgress, systemImage: "internaldrive.fill")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .pipeCard()

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: AppContent.copy.settings.disclaimer)
                        Text(AppContent.copy.educationalDisclaimer)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.danger)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .pipeCard()

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: AppContent.copy.settings.legal)
                        Link(destination: URL(string: AppContent.copy.termsURL)!) {
                            Label(AppContent.copy.paywall.terms, systemImage: "doc.text.fill")
                        }
                        Link(destination: URL(string: AppContent.copy.privacyURL)!) {
                            Label(AppContent.copy.paywall.privacy, systemImage: "hand.raised.fill")
                        }
                        Text(AppContent.copy.settings.appVersion)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.blue)
                    .pipeCard()

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label(AppContent.copy.settings.reset, systemImage: "trash.fill")
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
                .sectionSpacing()
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(AppContent.copy.settings.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(AppContent.copy.settings.resetConfirm, isPresented: $showResetConfirmation) {
            Button(AppContent.copy.settings.cancel, role: .cancel) {}
            Button(AppContent.copy.settings.resetNow, role: .destructive) {
                game.resetProgress()
            }
        } message: {
            Text(AppContent.copy.settings.resetConfirmMessage)
        }
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
