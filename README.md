# PipeBoss AI

Localization and listing drafts are documented in [LOCALIZATION.md](LOCALIZATION.md). Experience, retention and monetization priorities are in [GROWTH.md](GROWTH.md). The Spanish starter is a partial pilot with English fallback, not a fully translated release.

The version 1.0.2 release gates and native purchase testing are documented in [RELEASE.md](RELEASE.md).

PipeBoss AI is an offline-first SwiftUI plumbing training game with local skill history, spaced mistake practice, daily challenges, Pro exam sessions and shareable aggregate learning reports. All existing product IDs and price placeholders are unchanged.

## Project map

- `PipeBossAI/Content/AppContent.swift`: central editable app copy, product IDs, jobs, tools, upgrades, learning cards and onboarding.
- `PipeBossAI/Core/TrainingProgress.swift`: bounded attempt history, topic accuracy, review scheduling, learning streaks and daily rotation.
- `PipeBossAI/Core/Models.swift`: player, job, diagnosis, tool, learning, upgrade, subscription, and result models.
- `PipeBossAI/ViewModels`: gameplay state, local progress, job simulation state, rewards, unlock logic, and haptics triggers.
- `PipeBossAI/Services`: UserDefaults persistence, StoreKit 2 purchase manager, and haptics wrapper.
- `PipeBossAI/Views`: onboarding, dashboard, job board, simulation, inventory, upgrades, learning cards, skills, real personal achievements, pack previews, paywall and privacy/settings screens.
- `PipeBossAI/StoreKit/PipeBossAI.storekit`: local StoreKit configuration matching the App Store Connect product IDs in `AppContent.ProductIDs`.

## Before App Store submission

1. Add production app icons to `Assets.xcassets/AppIcon.appiconset`.
2. Add App Store screenshots and in-app purchase review screenshots.
3. Attach the subscriptions and in-app purchases to the app version before review.
4. Verify every safety statement against local regulations and qualified trade guidance.
5. Keep the public Terms and Privacy links available for App Review.

## Build and upload path from Windows

The repo includes a shared Xcode scheme and GitHub Actions workflows that use hosted macOS runners:

- `.github/workflows/ios-ci.yml`: builds Debug/Release, captures iPhone/iPad screens and tests all six products with StoreKitTest on both simulator families.
- `.github/workflows/ios-testflight.yml`: manually archives, exports, and optionally uploads a signed IPA to App Store Connect/TestFlight.

The CI workflow does not require Apple signing secrets. The TestFlight workflow requires these GitHub repository secrets:

- `APPLE_CERTIFICATE_BASE64`: base64 of an Apple Distribution `.p12` certificate.
- `APPLE_CERTIFICATE_PASSWORD`: password for the `.p12` certificate.
- `APPLE_PROVISIONING_PROFILE_BASE64`: base64 of the App Store provisioning profile for `com.pipebossai.app`.
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID.
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect issuer ID.
- `APP_STORE_CONNECT_API_KEY_BASE64`: base64 of the App Store Connect `.p8` API key.
- `KEYCHAIN_PASSWORD`: optional password for the temporary CI keychain. If omitted, the workflow uses the GitHub run ID.

PowerShell helpers for copying secret values:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AppleDistribution.p12")) | Set-Clipboard
[Convert]::ToBase64String([IO.File]::ReadAllBytes("PipeBossAI_AppStore.mobileprovision")) | Set-Clipboard
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_XXXXXXXXXX.p8")) | Set-Clipboard
```

After passing the release gates, run **Actions > iOS TestFlight Upload > Run workflow** from the verified commit. Enter build number `15` for version `1.0.2`, after confirming that number is unused in App Store Connect. Uploading to TestFlight does not submit the app to App Review.

Xcode Cloud is still an optional Apple-native path, but its first workflow must be created from Xcode on a Mac. The GitHub Actions path above is the Windows-friendly route for this project.

## App Store Connect product IDs

- `com.pipebossai.pro.monthly`
- `com.pipebossai.pro.yearly`
- `com.pipebossai.pack.city`
- `com.pipebossai.pack.advancedtools`
- `com.pipebossai.pack.emergency`
- `com.pipebossai.pack.businessowner`

The current MVP intentionally stores progress locally with UserDefaults and does not collect personal data.

## Experience and monetization update

- First recommended job opens directly; its timer begins after inspection, not during the customer brief.
- Practice and daily challenges cost no energy and grant no farmable career rewards. Incorrect decisions enter an immediate review queue; correct reviews move to 1, 3, 7 and 14-day intervals.
- Pro includes topic breakdowns, recent decisions, assessment sessions and an aggregate report export. Free users keep accuracy summaries and mistake practice.
- Pack previews show actual scenarios/tools and prerequisites. Owned packs link directly to content. Pro overlap and already-owned tool kits are disclosed.
- Trial copy appears only for an eligible StoreKit-provided free trial. No introductory offer or price schedule is created by the code.
- Fake leaderboard competitors and simulated ad rewards are removed. First-job hints are free; later free-plan hints cost 20 earned coins. A real rewarded-ad integration requires ad-network configuration, consent and updated privacy disclosures before it should be enabled.
- Native StoreKit review requests follow engagement thresholds and cooldowns without filtering by purchase or score.
- CI checks localization, metadata, persistence, entitlement access and practice rewards, builds iOS on macOS, and captures real Simulator iPhone/iPad screens using debug-only fixtures. Screenshots are artifacts, not automatically uploaded to the listing.
- Remote analytics, cloud sync, school licensing, paid acquisition, store-page experiments and professional translation/safety review still require external configuration or human validation; they are not represented as finished services.
