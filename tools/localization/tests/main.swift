import Foundation

var checks = 0
func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    precondition(condition(), message)
    checks += 1
}

check(L10n.language(for: "system", preferred: ["es-MX"], available: ["en", "es"]) == "es", "Regional Spanish should resolve to Spanish")
check(L10n.language(for: "system", preferred: ["ja"], available: ["en", "es"]) == "en", "Unsupported language should fall back")
check(L10n.language(for: "en", preferred: ["es"], available: ["en", "es"]) == "en", "Explicit English overrides device")
check(L10n.language(for: "missing", preferred: ["es"], available: ["en", "es"]) == "en", "Invalid stored preference is safe")
check(L10n.substitute("Nivel {level}: {item}", values: ["level": "3", "item": "Llave"]) == "Nivel 3: Llave", "Named substitution")
check(L10n.substitute("{item} {level}", values: ["item": "{level}", "level": "2"]) == "{level} 2", "Values must not be substituted recursively")
check(L10n.substitute("{level}/{level}", values: ["level": "2"]) == "2/2", "Repeated token")
check(L10n.substitute("🛠 {item}", values: ["item": "tubería"]) == "🛠 tubería", "Unicode token ranges")
check(L10n.substitute("100% {unknown}", values: [:]) == "100% {unknown}", "Literal percent and unknown token")
check(L10n.text("Unknown sentence", language: "zz") == "Unknown sentence", "Missing bundle fallback")

check(SubscriptionPricing.annualSavingsPercent(monthly: Decimal(string: "6.99")!, yearly: Decimal(string: "49.99")!, sameCurrency: true) == 40, "Savings from live prices should round down")
check(SubscriptionPricing.annualSavingsPercent(monthly: 0, yearly: 10, sameCurrency: true) == nil, "No division by zero")
check(SubscriptionPricing.annualSavingsPercent(monthly: 5, yearly: 70, sameCurrency: true) == nil, "No false discount")
check(SubscriptionPricing.annualSavingsPercent(monthly: 5, yearly: 50, sameCurrency: false) == nil, "No cross-currency comparison")

let products = AppContent.storeProducts.map(\.productID)
check(Set(products).count == 6, "Exactly six unique product IDs")
check(AppContent.jobs.count >= 25, "Training catalogue preserved")
check(AppContent.jobs.filter(\.isFreeStarterJob).count == 10, "Free beginner content preserved")
for job in AppContent.jobs {
    check(job.diagnosisQuestion.options.contains { $0.id == job.diagnosisQuestion.correctOptionID }, "Diagnosis identity preserved")
    check(job.repairOptions.contains { $0.id == job.correctRepairID }, "Repair identity preserved")
    check(job.requiredTools.allSatisfy { id in AppContent.tools.contains { $0.id == id } }, "Tool identity preserved")
}
var player = Player.newApprentice
player.completedJobIDs = [AppContent.jobs[0].id]
player.activeEntitlements = [AppContent.ProductIDs.proYearly]
let roundTrip = try JSONDecoder().decode(Player.self, from: JSONEncoder().encode(player))
check(roundTrip == player, "Localization must not change saved progress or entitlement IDs")
print("Passed \(checks) Swift content, formatting and pricing checks.")

var calendar = Calendar(identifier: .gregorian)
calendar.timeZone = TimeZone(secondsFromGMT: 0)!
let day = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5, hour: 12))!
let job = AppContent.jobs[0]
var training = TrainingProgress()
let correct = TrainingAttempt(job: job, diagnosisID: job.diagnosisQuestion.correctOptionID, repairID: job.correctRepairID, mode: .career, date: day)
let wrong = TrainingAttempt(job: job, diagnosisID: "wrong", repairID: "wrong", mode: .practice, date: day)
training.record(wrong, calendar: calendar)
check(training.dueJobIDs(now: day) == [job.id], "Mistakes must be available to practise immediately")
check(training.careerAttempts == 0 && training.totalAttempts == 1, "Practice is recorded separately")
training.record(correct, calendar: calendar)
check(training.dueJobIDs(now: day).isEmpty, "A successful review should be rescheduled")
check(training.reviews[job.id]?.consecutiveCorrect == 1, "Correct streak advances")
let tomorrow = calendar.date(byAdding: .day, value: 1, to: day)!
check(training.dueJobIDs(now: tomorrow) == [job.id], "First successful review is due the next day")
training.record(TrainingAttempt(job: job, diagnosisID: job.diagnosisQuestion.correctOptionID, repairID: job.correctRepairID, mode: .daily, date: tomorrow), calendar: calendar)
check(training.streak(now: tomorrow, calendar: calendar) == 2, "Consecutive local learning days")
check(training.completedDaily(now: tomorrow, calendar: calendar), "Completed daily challenge recognized")
check(!training.completedDaily(now: day, calendar: calendar), "Daily completion resets on a new day")
check(training.streak(now: calendar.date(byAdding: .day, value: 3, to: day)!, calendar: calendar) == 0, "A pause does not invent a streak")
check(training.totalAttempts == 3, "Lifetime attempt counter")
check(!training.shouldRequestReview(now: tomorrow), "Do not ask for review before engagement")
training.careerAttempts = 5
check(training.shouldRequestReview(now: tomorrow), "Review eligibility does not filter bad answers")
training.reviewRequestDates = [tomorrow]
check(!training.shouldRequestReview(now: tomorrow), "Review prompts have a cooldown")
let snapshot = try JSONDecoder().decode(TrainingProgress.self, from: JSONEncoder().encode(training))
check(snapshot == training, "Training history survives persistence")
for _ in 0..<510 { training.record(correct, calendar: calendar) }
check(training.attempts.count == 500, "History is bounded")
check(training.totalAttempts == 513, "Bounding history keeps lifetime totals")
check(TrainingProgress.dailyJob(from: [], now: day, calendar: calendar) == nil, "Empty daily catalogue is safe")
check(TrainingProgress.dailyJob(from: AppContent.jobs, now: day, calendar: calendar)?.isFreeStarterJob == true, "Daily challenge never requires payment")
check(TrainingProgress.dailyJob(from: AppContent.jobs, now: day, calendar: calendar) == TrainingProgress.dailyJob(from: AppContent.jobs, now: day, calendar: calendar), "Daily rotation is stable")
check(PackContent.jobs(for: AppContent.ProductIDs.emergencyJobs, in: AppContent.jobs).allSatisfy { $0.category == .emergency }, "Emergency pack content is exact")
check(PackContent.specialistToolIDs.count == 5, "Advanced tools count is honest")
check(AppContent.storeProducts[0].pricePlaceholder == "$6.99 / month" && AppContent.storeProducts[1].pricePlaceholder == "$49.99 / year", "Subscription prices must remain unchanged")
print("Passed \(checks) total Foundation checks including learning history and unchanged pricing.")
