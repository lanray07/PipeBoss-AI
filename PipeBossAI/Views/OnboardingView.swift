import SwiftUI

struct OnboardingView: View {
    @ObservedObject var game: GameViewModel
    @State private var pageIndex = 0
    @State private var apprenticeName = ""
    @EnvironmentObject private var localization: LocalizationPreferences

    private let pages = AppContent.onboardingPages

    var body: some View {
        GeometryReader { geometry in
        ZStack {
            PipeBackground()

            ScrollView {
            VStack(spacing: 24) {
                Picker(LocalizedStringKey(AppContent.copy.settings.language), selection: $localization.selection) {
                    ForEach(localization.languages) { language in
                        LText(language.name).tag(language.id)
                    }
                }.pickerStyle(.menu)
                Spacer(minLength: 24)

                VStack(spacing: 10) {
                    LText(AppContent.copy.appName)
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(AppTheme.navy)
                    LText(AppContent.copy.educationalDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: min(360, max(260, geometry.size.height * 0.38)))

                TextField(LocalizedStringKey(AppContent.copy.onboarding.namePlaceholder), text: $apprenticeName)
                    .textInputAutocapitalization(.words)
                    .padding(14)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(AppTheme.line, lineWidth: 1)
                    }
                    .padding(.horizontal, 24)

                Button {
                    if pageIndex < pages.count - 1 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            pageIndex += 1
                        }
                    } else {
                        game.completeOnboarding(name: apprenticeName)
                    }
                } label: {
                    LLabel(pageIndex == pages.count - 1 ? AppContent.copy.onboarding.startButton : AppContent.copy.onboarding.nextButton, systemImage: pageIndex == pages.count - 1 ? "play.fill" : "arrow.right")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.horizontal, 24)

                Spacer(minLength: 24)
            }
            .frame(minHeight: geometry.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.iconSystemName)
                .font(.system(size: 58, weight: .bold))
                .foregroundStyle(AppTheme.orange)
                .frame(width: 116, height: 116)
                .background(AppTheme.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(spacing: 10) {
                LText(page.title)
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                LText(page.subtitle)
                    .font(.body)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 28)
        }
        .padding()
    }
}
