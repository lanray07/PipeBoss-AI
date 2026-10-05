import SwiftUI

struct LocalUsageView: View {
    @ObservedObject var game: GameViewModel
    private func count(prefix: String) -> Int {
        game.training.eventCounts.filter { $0.key.hasPrefix(prefix) }.values.reduce(0, +)
    }
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 10) {
                LText(AppContent.copy.training.metricsSummary).font(.footnote).foregroundStyle(AppTheme.muted)
                row(AppContent.copy.training.careerSessions, count: game.training.careerAttempts)
                row(AppContent.copy.training.practiceSessions, count: game.training.totalAttempts - game.training.careerAttempts)
                row(AppContent.copy.training.storeVisits, count: count(prefix: "store."))
                row(AppContent.copy.training.purchases, count: count(prefix: "purchase.verified."))
                row(AppContent.copy.training.restores, count: count(prefix: "restore.completed"))
            }.padding(.top, 10)
        } label: {
            LLabel(AppContent.copy.training.localMetrics, systemImage: "chart.bar")
        }
    }
    private func row(_ title: String, count: Int) -> some View {
        HStack {
            LText(title)
            Spacer()
            Text(count, format: .number).monospacedDigit()
        }.font(.subheadline)
    }
}
