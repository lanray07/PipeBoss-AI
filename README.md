# PipeBoss AI

PipeBoss AI is a SwiftUI plumbing training game MVP. It is offline-first, MVVM-oriented, and ready to expand with production legal URLs, final screenshots, and analytics/cloud services.

## Project map

- `PipeBossAI/Content/AppContent.swift`: central editable app copy, product IDs, jobs, tools, upgrades, learning cards, onboarding, and leaderboard sample data.
- `PipeBossAI/Core/Models.swift`: player, job, diagnosis, tool, learning, upgrade, subscription, and result models.
- `PipeBossAI/ViewModels`: gameplay state, local progress, job simulation state, rewards, unlock logic, and haptics triggers.
- `PipeBossAI/Services`: UserDefaults persistence, StoreKit 2 purchase manager, and haptics wrapper.
- `PipeBossAI/Views`: onboarding, dashboard, job board, simulation, inventory, upgrades, learning cards, leaderboard, paywall, and privacy/settings screens.
- `PipeBossAI/StoreKit/PipeBossAI.storekit`: local StoreKit configuration matching the App Store Connect product IDs in `AppContent.ProductIDs`.

## Before App Store submission

1. Replace the placeholder terms and privacy URLs in `AppContent.swift`.
2. Add production app icons to `Assets.xcassets/AppIcon.appiconset`.
3. Add App Store screenshots and in-app purchase review screenshots.
4. Attach the subscriptions and in-app purchases to the app version before review.
5. Verify every safety statement against local regulations and qualified trade guidance.

## Build and upload path

The repo includes a shared Xcode scheme and a GitHub Actions workflow at `.github/workflows/ios-ci.yml` so GitHub can run a simulator build on a hosted macOS runner.

For App Store/TestFlight upload, use Xcode Cloud after a one-time setup in Xcode:

1. Open `PipeBossAI.xcodeproj` on a Mac with Xcode.
2. Sign in with the Apple Developer account and select team `5ZP6GV85J6`.
3. Confirm the bundle identifier is `com.pipebossai.app`.
4. Create the first Xcode Cloud workflow for the `PipeBossAI` scheme on the `main` branch.
5. Start the first archive build, then manage later builds from App Store Connect > Xcode Cloud.

If no local Mac is available, use a temporary cloud Mac to do the first Xcode Cloud workflow setup. After that, App Store Connect can launch and monitor builds in the browser.

## App Store Connect product IDs

- `com.pipebossai.pro.monthly`
- `com.pipebossai.pro.yearly`
- `com.pipebossai.pack.city`
- `com.pipebossai.pack.advancedtools`
- `com.pipebossai.pack.emergency`
- `com.pipebossai.pack.businessowner`

The current MVP intentionally stores progress locally with UserDefaults and does not collect personal data.
