# Version 1.0.2 (16) readiness — 6 October 2026

## Completed

- Synced the workspace with release commit `dee2d3691e6cbf0ddaef3be037ad1aa15b78352c`.
- Replaced the revoked PipeBoss signing certificate and invalid provisioning profile. The new profile is ACTIVE. Other apps' signing certificates were retained.
- Updated the existing GitHub signing secrets. Private material remains outside Git in the ignored Signing directory.
- Signed archive, IPA export and App Store Connect upload passed: https://github.com/lanray07/PipeBoss-AI/actions/runs/37486546739
- Apple processed 1.0.2 (15) successfully (VALID, APP_STORE_ELIGIBLE), and it was attached to the editable 1.0.2 version before the restore repair.
- Internal TestFlight state is IN_BETA_TESTING. The existing PipeBoss Beta Testers group automatically includes build 15 and contains the owner's one existing tester account. TestFlight notes are saved in English (U.K.). Proof: AppStoreAssets/ReleaseProof/testflight-1.0.2-15.png and release-verification.json.
- Earlier build 15 app code passed iOS CI and StoreKit integration on both simulator families: https://github.com/lanray07/PipeBoss-AI/actions/runs/37407322146
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

Install **1.0.2 (16)** from TestFlight. Build 15 has a failed restore check; do not test the public 1.0.1 app or expired build 14.

1. Finish onboarding and a beginner job. Check diagnosis, repair feedback, XP/coins and progress after force quit/relaunch.
2. Try the daily challenge, energy-free practice, mistake review and Skills. Confirm practice does not grant career XP/coins or use career energy.
3. In Home > Open PipeBoss Store, confirm both subscriptions and all four packs load with localized Apple prices. Test purchase cancellation, subscription access, each pack's included content and disclosed level/tool requirements using Apple's test environment.
4. Check Restore Purchases, access after relaunch, subscription expiry where testable, and Manage Subscription. Verify Terms and Privacy links.
5. Disable connectivity after loading content and verify gameplay and saved progress. Purchases require connectivity.
6. Check small-screen scrolling and iPad layouts where available. Report crashes, inaccessible controls, misleading copy or lost progress before submission.

## Owner's iPhone checks — 6 October 2026

- Owner reports the iPhone appearance looks alright.
- Supplied TestFlight screenshot shows Emergency Jobs Pack and Business Owner Mode marked Owned. This confirms those entitlements are recognized in the displayed session; persistence after relaunch has not yet been confirmed.
- Restore Purchases produced “Restore did not complete. Try again from the App Store account used to subscribe.” Build 15 maps any error from AppStore.sync() to that generic text, so the screenshot does not identify the underlying StoreKit error or prove an account mismatch. The owner confirmed completing the password authentication prompt. Restore QA has not passed; do not submit until resolved and retested.
- Offline saved-progress checks and the other purchase scenarios remain unconfirmed.

Version 1.0.2 remains a submission draft. No complete real-device QA pass is claimed.

## Restore fix — build 16

- Reproduced failed-sync handling and cancellation faults in StoreKit regression run 37501316174: stale verified-entitlement state, lost diagnostic code and misleading account-mismatch text. Apple's original device sync failure itself is not reproduced or identified by that injection.
- PR #2 refreshes verified entitlements after sync failure, reports cancellation quietly, distinguishes network/authentication failures, and shows a sanitized support reference without account, URL or transaction details. Failed sync is not counted as success. Successful refreshes display a confirmation or no-active-purchases result.
- The new tests cover verified ownership, refunds, error privacy and retry recovery. Full native CI passed in https://github.com/lanray07/PipeBoss-AI/actions/runs/37502821739: Debug Simulator and Release device builds, native captures and all 11 StoreKit tests on each of iPhone and iPad. The first attempt had an Xcode test-fixture certificate failure; the fresh-runner retry passed without weakening verification. PR #2 merged as 1ad7d21084b2e251e737a0c83f981d2570977de5. Build number 16 was confirmed unused before upload preparation.
- Signed build 16 archive, export and upload passed: https://github.com/lanray07/PipeBoss-AI/actions/runs/37507204318. Apple processed the build as VALID and APP_STORE_ELIGIBLE. Build 16 is IN_BETA_TESTING in the existing PipeBoss Beta Testers group, its English retest notes are saved, and it replaces build 15 in the editable 1.0.2 draft. Proof: AppStoreAssets/ReleaseProof/testflight-1.0.2-16.png and restore-build16-verification.json.
- Build 16 must be tested on the owner's iPhone: complete Restore Purchases authentication, check the confirmation and Owned packs, relaunch, and verify offline saved progress. If sync still fails, capture the support reference. Do not submit on the basis of a failed-sync fallback or the older build 15 check.

## Build 16 device retest — 7 October 2026

- Owner confirms Emergency Jobs Pack and Business Owner Mode remain Owned after relaunch; the supplied 06:25 screenshot shows both Owned states.
- The subsequent 06:27 Restore Purchases screenshot reports `Support reference: StoreKit.unknown`. Restore synchronization still fails. Build 16 fixes error handling and verified-entitlement refresh, but does not resolve the device synchronization failure.
- Saved evidence: AppStoreAssets/ReleaseProof/restore-build16-device-error-2026-10-07.png. The screenshot identifies the StoreKit error category, not its underlying cause.
- Read-only App Store Connect recheck confirms both subscriptions and all four non-consumable packs APPROVED, selected build 16 VALID, and version PREPARE_FOR_SUBMISSION. These checks do not establish the cause of the failed sync.
- Owner confirms completing the password prompt for the build 16 attempt and using an iPhone 16 Pro Max and iPad 8th generation. OS versions and whether the identical error occurs on both devices are requested. A failing device reproduction or focused StoreKit diagnostic is required before claiming a root-cause fix; simulator fault injection does not reproduce Apple's sync failure.
- Release remains blocked on restore investigation. Do not submit or count persistent ownership as a successful sync. Offline saved-progress and other unconfirmed QA checks remain outstanding.