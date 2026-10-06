import Foundation

enum TrainingMode: String, Codable {
    case career, practice, daily, exam
}

struct TrainingAttempt: Identifiable, Codable, Equatable {
    let id: UUID
    let jobID: String
    let category: JobCategory
    let date: Date
    let mode: TrainingMode
    let diagnosisID: String
    let repairID: String
    let diagnosisCorrect: Bool
    let repairCorrect: Bool

    init(job: JobScenario, diagnosisID: String, repairID: String, mode: TrainingMode, date: Date = Date()) {
        id = UUID()
        jobID = job.id
        category = job.category
        self.date = date
        self.mode = mode
        self.diagnosisID = diagnosisID
        self.repairID = repairID
        diagnosisCorrect = diagnosisID == job.diagnosisQuestion.correctOptionID
        repairCorrect = repairID == job.correctRepairID
    }

    var correct: Bool { diagnosisCorrect && repairCorrect }
}

struct ScheduledReview: Codable, Equatable {
    var jobID: String
    var consecutiveCorrect: Int
    var dueDate: Date
    var needsRework: Bool
}

struct TopicPerformance: Identifiable {
    let category: JobCategory
    let attempts: [TrainingAttempt]
    var id: String { category.rawValue }
    var diagnosisAccuracy: Double { accuracy(\.diagnosisCorrect) }
    var repairAccuracy: Double { accuracy(\.repairCorrect) }
    private func accuracy(_ key: KeyPath<TrainingAttempt, Bool>) -> Double {
        guard !attempts.isEmpty else { return 0 }
        return Double(attempts.filter { $0[keyPath: key] }.count) / Double(attempts.count)
    }
}

// Bounded, device-only learning history. It has no advertising IDs or network transport.
struct TrainingProgress: Codable, Equatable {
    var attempts: [TrainingAttempt] = []
    var reviews: [String: ScheduledReview] = [:]
    var totalAttempts = 0
    var careerAttempts = 0
    var learningDays: [Date] = []
    var reviewRequestDates: [Date] = []
    var eventCounts: [String: Int] = [:]

    mutating func record(_ attempt: TrainingAttempt, calendar: Calendar = .current) {
        attempts.append(attempt)
        attempts = Array(attempts.suffix(500))
        totalAttempts += 1
        if attempt.mode == .career { careerAttempts += 1 }
        let day = calendar.startOfDay(for: attempt.date)
        if !learningDays.contains(where: { calendar.isDate($0, inSameDayAs: day) }) {
            learningDays.append(day)
            learningDays = Array(learningDays.sorted().suffix(366))
        }
        let consecutive = attempt.correct ? (reviews[attempt.jobID]?.consecutiveCorrect ?? 0) + 1 : 0
        let interval = attempt.correct ? [1, 3, 7, 14][min(consecutive - 1, 3)] : 0
        reviews[attempt.jobID] = ScheduledReview(
            jobID: attempt.jobID, consecutiveCorrect: consecutive,
            dueDate: calendar.date(byAdding: .day, value: interval, to: attempt.date) ?? attempt.date,
            needsRework: !attempt.correct
        )
        recordEvent("completed.\(attempt.mode.rawValue)")
    }

    mutating func recordEvent(_ name: String) {
        eventCounts[name, default: 0] += 1
    }

    func dueJobIDs(now: Date = Date()) -> [String] {
        reviews.values.filter { $0.dueDate <= now }
            .sorted {
                if $0.needsRework != $1.needsRework { return $0.needsRework }
                if $0.dueDate == $1.dueDate { return $0.jobID < $1.jobID }
                return $0.dueDate < $1.dueDate
            }.map(\.jobID)
    }

    func streak(now: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = Set(learningDays.map { calendar.startOfDay(for: $0) })
        var day = calendar.startOfDay(for: now)
        if !days.contains(day) { day = calendar.date(byAdding: .day, value: -1, to: day) ?? day }
        var count = 0
        while days.contains(day) {
            count += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? .distantPast
        }
        return count
    }

    func completedDaily(now: Date = Date(), calendar: Calendar = .current) -> Bool {
        attempts.contains { $0.mode == .daily && calendar.isDate($0.date, inSameDayAs: now) }
    }

    func shouldRequestReview(now: Date = Date(), calendar: Calendar = .current) -> Bool {
        // Never filter by accuracy, star rating, subscription, or payment status.
        guard careerAttempts >= 5, learningDays.count >= 2 else { return false }
        let recent = reviewRequestDates.filter { now.timeIntervalSince($0) < 365 * 86_400 }
        guard recent.count < 3 else { return false }
        return recent.max().map { now.timeIntervalSince($0) >= 90 * 86_400 } ?? true
    }

    static func dailyJob(from jobs: [JobScenario], now: Date = Date(), calendar: Calendar = .current) -> JobScenario? {
        let starter = jobs.filter(\.isFreeStarterJob).sorted { $0.id < $1.id }
        guard !starter.isEmpty else { return nil }
        let parts = calendar.dateComponents([.year, .month, .day], from: now)
        let seed = (parts.year ?? 0) * 372 + (parts.month ?? 0) * 31 + (parts.day ?? 0)
        return starter[abs(seed) % starter.count]
    }
}

enum PackContent {
    static let specialistToolIDs = ["inspection-camera", "pipe-freeze-kit", "press-tool", "thermal-camera", "drain-camera"]

    static func jobs(for productID: String, in jobs: [JobScenario]) -> [JobScenario] {
        jobs.filter { job in
            switch productID {
            case AppContent.ProductIDs.cityExpansion: return [.commercial, .installation].contains(job.category)
            case AppContent.ProductIDs.emergencyJobs: return job.category == .emergency
            case AppContent.ProductIDs.businessOwnerMode: return job.category == .business
            default: return false
            }
        }
    }
}
