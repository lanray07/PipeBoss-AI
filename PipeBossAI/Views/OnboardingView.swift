import SwiftUI

struct OnboardingView: View {
    @ObservedObject var game: GameViewModel
    @State private var pageIndex = 0
    @State private var apprenticeName = ""

    private let pages = AppContent.onboardingPages

    var body: some View {
        ZStack {
            PipeBackground()

            VStack(spacing: 24) {
                Spacer(minLength: 24)

                VStack(spacing: 10) {
                    Text(AppContent.copy.appName)
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(AppTheme.navy)
                    Text(AppContent.copy.educationalDisclaimer)
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
                .frame(height: 360)

                TextField(AppContent.copy.onboarding.namePlaceholder, text: $apprenticeName)
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
                    Label(pageIndex == pages.count - 1 ? AppContent.copy.onboarding.startButton : AppContent.copy.onboarding.nextButton, systemImage: pageIndex == pages.count - 1 ? "play.fill" : "arrow.right")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.horizontal, 24)

                Spacer(minLength: 24)
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
                Text(page.title)
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
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
