import Foundation

enum JobDifficulty: String, Codable, CaseIterable, Identifiable, Hashable {
    case beginner
    case intermediate
    case advanced
    case heating
    case commercial
    case emergency

    var id: String { rawValue }
}

enum JobCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case leaks
    case drainage
    case fixtures
    case heating
    case installation
    case commercial
    case emergency
    case business

    var id: String { rawValue }
}

enum ToolCategory: String, Codable, CaseIterable, Identifiable {
    case handTools
    case drainage
    case testing
    case heating
    case specialist

    var id: String { rawValue }
}

enum UpgradeCategory: String, Codable, CaseIterable, Identifiable {
    case vehicle
    case workshop
    case training
    case marketing
    case business

    var id: String { rawValue }
}

enum StoreProductKind: String, Codable {
    case monthlySubscription
    case yearlySubscription
    case nonConsumable
}

enum RewardedAdReward: String, Codable, CaseIterable, Identifiable {
    case coins
    case energy
    case hint

    var id: String { rawValue }
}

struct DecisionOption: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let detail: String
}

struct DiagnosisQuestion: Identifiable, Codable, Hashable {
    let id: String
    let prompt: String
    let options: [DecisionOption]
    let correctOptionID: String
    let explanation: String
}

struct JobScenario: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let customerComplaint: String
    let difficulty: JobDifficulty
    let category: JobCategory
    let requiredLevel: Int
    let requiredTools: [String]
    let symptoms: [String]
    let diagnosisQuestion: DiagnosisQuestion
    let repairOptions: [DecisionOption]
    let correctRepairID: String
    let timeLimitMinutes: Int
    let rewardCoins: Int
    let rewardXP: Int
    let learningTip: String
    let mentorHint: String
    let safetyWarning: String
    let isPremium: Bool
    let isFreeStarterJob: Bool
    let iconSystemName: String
}

struct ToolItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: ToolCategory
    let summary: String
    let cost: Int
    let requiredLevel: Int
    let performanceBoost: Int
    let isStarterTool: Bool
    let iconSystemName: String
}

struct LearningCard: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let topic: String
    let summary: String
    let bulletPoints: [String]
    let requiredLevel: Int
    let isPremium: Bool
    let iconSystemName: String
}

struct Upgrade: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: UpgradeCategory
    let summary: String
    let cost: Int
    let requiredLevel: Int
    let effectDescription: String
    let iconSystemName: String
    let isPremium: Bool
}

struct SubscriptionProduct: Identifiable, Codable, Hashable {
    let id: String
    let productID: String
    let displayName: String
    let subtitle: String
    let pricePlaceholder: String
    let kind: StoreProductKind
    let benefits: [String]
}

struct OnboardingPage: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let iconSystemName: String
}

struct LeaderboardEntry: Identifiable, Codable, Hashable {
    let id: String
    let rank: Int
    let name: String
    let level: Int
    let reputation: Double
    let badge: String
}

struct JobOutcome: Identifiable, Equatable {
    let id = UUID()
    let jobID: String
    let jobTitle: String
    let diagnosisCorrect: Bool
    let repairCorrect: Bool
    let xpAwarded: Int
    let coinsAwarded: Int
    let rating: Double
    let reputationChange: Double
    let message: String
    let learningTip: String
    let safetyWarning: String
}

struct Player: Codable, Equatable {
    var name: String
    var xp: Int
    var coins: Int
    var reputation: Double
    var energy: Int
    var maxEnergy: Int
    var completedJobIDs: [String]
    var ownedToolIDs: [String]
    var purchasedUpgradeIDs: [String]
    var unlockedLearningCardIDs: [String]
    var activeEntitlements: [String]
    var hasCompletedOnboarding: Bool
    var dailyJobCount: Int
    var lastEnergyRefresh: Date

    static let newApprentice = Player(
        name: "Apprentice",
        xp: 0,
        coins: 250,
        reputation: 3.5,
        energy: 5,
        maxEnergy: 5,
        completedJobIDs: [],
        ownedToolIDs: [
            "adjustable-wrench",
            "screwdriver-set",
            "plunger",
            "bucket",
            "ptfe-tape",
            "radiator-key"
        ],
        purchasedUpgradeIDs: [],
        unlockedLearningCardIDs: ["safety-basics", "hand-tool-basics"],
        activeEntitlements: [],
        hasCompletedOnboarding: false,
        dailyJobCount: 0,
        lastEnergyRefresh: Date()
    )

    var level: Int {
        max(1, min(30, (xp / 120) + 1))
    }

    var xpIntoCurrentLevel: Int {
        xp % 120
    }

    var xpProgress: Double {
        Double(xpIntoCurrentLevel) / 120.0
    }

    var careerTitle: String {
        switch level {
        case 1...3:
            return "Apprentice Plumber"
        case 4...8:
            return "Improver Plumber"
        case 9...14:
            return "Qualified Plumber"
        case 15...22:
            return "Lead Engineer"
        default:
            return "Master Plumber"
        }
    }

    var hasPipeBossPro: Bool {
        activeEntitlements.contains(AppContent.ProductIDs.proMonthly)
            || activeEntitlements.contains(AppContent.ProductIDs.proYearly)
    }

    mutating func refreshEnergyIfNeeded(now: Date = Date()) {
        guard !Calendar.current.isDate(lastEnergyRefresh, inSameDayAs: now) else { return }
        energy = maxEnergy
        dailyJobCount = 0
        lastEnergyRefresh = now
    }
}
