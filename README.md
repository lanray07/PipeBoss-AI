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

## Build and upload path from Windows

The repo includes a shared Xcode scheme and GitHub Actions workflows that use hosted macOS runners:

- `.github/workflows/ios-ci.yml`: builds the app for the iOS Simulator on every push and pull request.
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

After adding the secrets in GitHub, run **Actions > iOS TestFlight Upload > Run workflow**. Leave `build_number` blank to use the GitHub run number, or enter a higher number manually if App Store Connect already has a build for version `1.0`.

Xcode Cloud is still an optional Apple-native path, but its first workflow must be created from Xcode on a Mac. The GitHub Actions path above is the Windows-friendly route for this project.

## App Store Connect product IDs

- `com.pipebossai.pro.monthly`
- `com.pipebossai.pro.yearly`
- `com.pipebossai.pack.city`
- `com.pipebossai.pack.advancedtools`
- `com.pipebossai.pack.emergency`
- `com.pipebossai.pack.businessowner`

The current MVP intentionally stores progress locally with UserDefaults and does not collect personal data.
