import Foundation

// Compile the real content models instead of scraping Swift with regular expressions.
let excluded = Set([
    "id", "productID", "pricePlaceholder", "correctOptionID", "correctRepairID",
    "requiredTools", "iconSystemName", "termsURL", "privacyURL", "appName", "proName"
])
var contexts: [String: Set<String>] = [:]

func collect(_ value: Any, path: String) {
    if let string = value as? String {
        guard !string.isEmpty else { return }
        contexts[string, default: []].insert(path)
        return
    }
    let mirror = Mirror(reflecting: value)
    for (index, child) in mirror.children.enumerated() {
        let label = child.label ?? String(index)
        let isDisplayLabel = label == "requiredTools" && child.value is String
        guard (!excluded.contains(label) || isDisplayLabel), !(path.hasPrefix("leaderboard") && label == "name") else { continue }
        // Raw enum values are identifiers, not displayed copy.
        guard Mirror(reflecting: child.value).displayStyle != .enum else { continue }
        collect(child.value, path: "\(path).\(label)")
    }
}

collect(AppContent.copy, path: "copy")
collect(AppContent.onboardingPages, path: "onboarding")
collect(AppContent.storeProducts, path: "products")
collect(AppContent.tools, path: "tools")
collect(AppContent.upgrades, path: "upgrades")
collect(AppContent.learningCards, path: "cards")
collect(AppContent.jobs, path: "jobs")
for difficulty in JobDifficulty.allCases {
    collect(AppContent.copy.difficultyTitle(difficulty), path: "difficulty.\(difficulty.rawValue)")
}
for category in JobCategory.allCases {
    collect(AppContent.copy.categoryTitle(category), path: "category.\(category.rawValue)")
}
for category in ToolCategory.allCases {
    collect(AppContent.copy.toolCategoryTitle(category), path: "toolCategory.\(category.rawValue)")
}
for category in UpgradeCategory.allCases {
    collect(AppContent.copy.upgradeCategoryTitle(category), path: "upgradeCategory.\(category.rawValue)")
}

let entries = contexts.mapValues { paths -> [String: Any] in
    [
        "contexts": paths.sorted(),
        "requiresSafetyReview": paths.contains {
            $0.contains("safetyWarning") || $0.contains("educationalDisclaimer")
                || $0.contains("diagnosisQuestion") || $0.contains("repairOptions")
                || $0.hasPrefix("cards.") || $0.contains("learningTip") || $0.contains("mentorHint")
        }
    ]
}
let data = try JSONSerialization.data(
    withJSONObject: ["sourceLanguage": "en", "entries": entries],
    options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
)
guard CommandLine.arguments.count == 2 else {
    fatalError("Usage: export-content path/to/source.json")
}
try (data + Data("\n".utf8)).write(to: URL(fileURLWithPath: CommandLine.arguments[1]), options: .atomic)
print("Exported \(entries.count) unique strings from the real app content.")
