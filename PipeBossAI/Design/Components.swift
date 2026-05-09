import SwiftUI

struct PipeBackground: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppTheme.pageGradient.ignoresSafeArea()
            PipePattern()
                .stroke(AppTheme.blue.opacity(0.09), style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))
                .frame(width: 260, height: 220)
                .offset(x: 80, y: -30)
                .allowsHitTesting(false)
        }
    }
}

struct PipePattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 20, y: rect.minY + 40))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + 40))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 30, y: rect.midY))
        path.move(to: CGPoint(x: rect.midX - 70, y: rect.maxY - 30))
        path.addLine(to: CGPoint(x: rect.midX - 70, y: rect.midY + 20))
        path.addLine(to: CGPoint(x: rect.maxX - 80, y: rect.midY + 20))
        return path
    }
}

struct HeroHeader: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 16)
                Image(systemName: icon)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.amber)
                    .frame(width: 58, height: 58)
                    .background(.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(20)
        .background {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.heroGradient
                PipePattern()
                    .stroke(.white.opacity(0.12), style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                    .frame(width: 220, height: 180)
                    .offset(x: 40, y: 50)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SectionTitle: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.ink)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pipeCard()
    }
}

struct XPProgressBar: View {
    let progress: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.blue)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppTheme.line.opacity(0.65))
                    Capsule()
                        .fill(LinearGradient(colors: [AppTheme.blue, AppTheme.sky], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, proxy.size.width * progress))
                }
            }
            .frame(height: 10)
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: JobDifficulty

    var body: some View {
        Text(AppContent.copy.difficultyTitle(difficulty))
            .font(.caption.bold())
            .foregroundStyle(foreground)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(background.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var foreground: Color {
        switch difficulty {
        case .beginner:
            return AppTheme.success
        case .intermediate:
            return AppTheme.blue
        case .advanced:
            return AppTheme.orange
        case .heating:
            return .red
        case .commercial:
            return AppTheme.navy
        case .emergency:
            return AppTheme.danger
        }
    }

    private var background: Color { foreground }
}

struct IconBadge: View {
    let icon: String
    let tint: Color

    var body: some View {
        Image(systemName: icon)
            .font(.headline)
            .foregroundStyle(tint)
            .frame(width: 42, height: 42)
            .background(tint.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct LockRibbon: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "lock.fill")
            .font(.caption.bold())
            .foregroundStyle(.white)
            .lineLimit(2)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppTheme.navy.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct RatingStars: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: Double(index) <= rating.rounded() ? "star.fill" : "star")
                    .foregroundStyle(AppTheme.amber)
                    .font(.caption)
            }
        }
        .accessibilityLabel("\(String(format: "%.1f", rating)) star rating")
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(icon: icon, tint: AppTheme.blue)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }
            Spacer()
        }
    }
}

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(AppTheme.blue)
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .pipeCard()
    }
}
