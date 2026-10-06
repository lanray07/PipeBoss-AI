# Version 1.0.2 (15) readiness — 6 October 2026

## Completed

- Synced the workspace with release commit `dee2d3691e6cbf0ddaef3be037ad1aa15b78352c`.
- Replaced the revoked PipeBoss signing certificate and invalid provisioning profile. The new profile is ACTIVE. Other apps' signing certificates were retained.
- Updated the existing GitHub signing secrets. Private material remains outside Git in the ignored Signing directory.
- Signed archive, IPA export and App Store Connect upload passed: https://github.com/lanray07/PipeBoss-AI/actions/runs/37486546739
- Apple processed 1.0.2 (15) successfully (VALID, APP_STORE_ELIGIBLE), and it is attached to the editable 1.0.2 version.
- Internal TestFlight state is IN_BETA_TESTING. The existing PipeBoss Beta Testers group automatically includes build 15 and contains the owner's one existing tester account. TestFlight notes are saved in English (U.K.). Proof: AppStoreAssets/ReleaseProof/testflight-1.0.2-15.png and release-verification.json.
- Current app code passed iOS CI and StoreKit integration on both simulator families: https://github.com/lanray07/PipeBoss-AI/actions/runs/37407322146
- Restored and visually inspected all 12 checksum-verified native screenshots from that CI run. Dashboard, diagnosis, result, skills, tools and learning screens are readable on iPhone and iPad. Local evidence is under DerivedData/ReleaseVerification/native.
- Public Privacy, Terms and Support gists return HTTP 200, are public, and match the current source documents.
- App Privacy is published as Data Not Collected; the source privacy manifest declares local UserDefaults access. The build declares no non-exempt encryption.
- App Information contains an age rating (4+ with regional ratings), Education category, content-rights declaration and trader identification.
- Replaced old mixed/duplicate screenshot sets with 1,000 optimized marketing images across all 50 locales: four each for iPhone 6.5-inch, iPhone 6.7-inch and iPad 12.9-inch, plus eight Duo images (four outer/four inner). All 200 sets passed read-only verification for count, exact order and COMPLETE processing state, with zero errors. Evidence: AppStoreAssets/ReleaseProof/optimized-screenshot-verification.json and optimized-duo-en-GB.png / optimized-duo-fr-FR.png.
- Optimized images show complete current native iPhone/iPad captures with large keyworded headlines. Captions are machine-translated; depicted UI and listing metadata remain English, disclosed in each image's localized footer. Duo compositions reuse the iPhone/iPad captures and do not establish native Duo compatibility or native-language editorial review. Sources and rendering/upload workflow are retained in AppStoreAssets/SourceCaptures/1.0.2 and tools.
- The stored review-note source now matches the caption-localization clarification saved in App Store Connect.
- Added a text-free navy/orange plumbing header to version 1.0.2, exported as a 3840 × 1646 opaque RGB PNG. English (U.K.) shows 1 of 1 Header Asset; French confirms it uses the primary header. Artwork and prompt are retained under AppStoreAssets/Creative/Header-1.0.2, with UI proof under AppStoreAssets/ReleaseProof/header-en-GB.png.

## Still required before submission

- Real-device TestFlight checks below. The owner confirmed that an iPhone or iPad is available. Simulator tests do not replace these checks.
- Final screenshot/caption accuracy review and App Store submission validation. The Header asset is now populated. The optional Search Results creative slot can remain empty; https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets confirms creative assets are optional.

## TestFlight checks for the owner

Install **1.0.2 (15)** from TestFlight. Do not test the public 1.0.1 app or expired build 14.

1. Finish onboarding and a beginner job. Check diagnosis, repair feedback, XP/coins and progress after force quit/relaunch.
2. Try the daily challenge, energy-free practice, mistake review and Skills. Confirm practice does not grant career XP/coins or use career energy.
3. In Home > Open PipeBoss Store, confirm both subscriptions and all four packs load with localized Apple prices. Test purchase cancellation, subscription access, each pack's included content and disclosed level/tool requirements using Apple's test environment.
4. Check Restore Purchases, access after relaunch, subscription expiry where testable, and Manage Subscription. Verify Terms and Privacy links.
5. Disable connectivity after loading content and verify gameplay and saved progress. Purchases require connectivity.
6. Check small-screen scrolling and iPad layouts where available. Report crashes, inaccessible controls, misleading copy or lost progress before submission.

No real-device QA result is claimed yet. Version 1.0.2 remains a submission draft.
