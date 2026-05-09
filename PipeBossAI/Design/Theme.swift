import SwiftUI

enum AppTheme {
    static let navy = Color(red: 0.04, green: 0.10, blue: 0.18)
    static let deepNavy = Color(red: 0.02, green: 0.06, blue: 0.12)
    static let blue = Color(red: 0.05, green: 0.36, blue: 0.78)
    static let sky = Color(red: 0.20, green: 0.66, blue: 0.94)
    static let orange = Color(red: 0.96, green: 0.43, blue: 0.13)
    static let amber = Color(red: 1.00, green: 0.70, blue: 0.25)
    static let ink = Color(red: 0.09, green: 0.13, blue: 0.20)
    static let muted = Color(red: 0.40, green: 0.46, blue: 0.54)
    static let surface = Color(red: 0.98, green: 0.99, blue: 1.00)
    static let line = Color(red: 0.84, green: 0.88, blue: 0.94)
    static let success = Color(red: 0.05, green: 0.58, blue: 0.35)
    static let danger = Color(red: 0.84, green: 0.14, blue: 0.15)

    static let pageGradient = LinearGradient(
        colors: [Color(red: 0.94, green: 0.98, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [deepNavy, navy, blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.line.opacity(0.8), lineWidth: 1)
            }
            .shadow(color: AppTheme.navy.opacity(0.08), radius: 16, x: 0, y: 8)
    }
}

extension View {
    func pipeCard() -> some View {
        modifier(CardModifier())
    }

    func sectionSpacing() -> some View {
        padding(.horizontal, 20)
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(configuration.isPressed ? AppTheme.orange.opacity(0.75) : AppTheme.orange)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(configuration.isPressed ? AppTheme.blue.opacity(0.10) : AppTheme.blue.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.blue.opacity(0.18), lineWidth: 1)
            }
    }
}

struct PlainIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.navy)
            .frame(width: 44, height: 44)
            .background(configuration.isPressed ? AppTheme.line : AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.line, lineWidth: 1)
            }
    }
}
