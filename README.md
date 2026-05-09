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

## App Store Connect product IDs

- `com.pipebossai.pro.monthly`
- `com.pipebossai.pro.yearly`
- `com.pipebossai.pack.city`
- `com.pipebossai.pack.advancedtools`
- `com.pipebossai.pack.emergency`
- `com.pipebossai.pack.businessowner`

The current MVP intentionally stores progress locally with UserDefaults and does not collect personal data.
