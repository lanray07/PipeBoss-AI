# Build 16 restore investigation — 7 October 2026

## Confirmed result

Restore Purchases fails with `StoreKit.unknown` after the owner's completed Apple password authentication. The owner confirms the same failure on iPhone 16 Pro Max (reported iOS 26.3.1(a)) and iPad 8th generation (reported iPadOS 26.7). Emergency Jobs Pack and Business Owner Mode remain Owned after relaunch. This is not a successful synchronization.

Build 16 uses the supported, explicitly user-triggered `AppStore.sync()` call. Its failed-sync handler refreshes verified current entitlements and reports the error. Simulator regression tests prove that handling, but cannot reproduce this Apple sandbox failure. No root-cause fix is established.

## Controlled reproduction

1. Keep signed TestFlight version 1.0.2 (16), the purchasing Apple Account and purchase history unchanged.
2. On iPhone, turn Wi-Fi off and use mobile data. Change only the network for this attempt.
3. Open Home > Open PipeBoss Store. Scroll below Terms and Privacy to Restore Purchases.
4. Record the local time and tap Restore Purchases once. Complete Apple's authentication if requested.
5. Record the exact result and whether both packs remain Owned. Record the interval from tapping Restore to the result, without assuming it represents a timeout.
6. A successful attempt must display the completed-refresh confirmation. A fallback that retains ownership with an error remains a failed sync.

Mobile-data result: pending. No account resets, transaction clearing, reinstall or purchase is needed for this comparison.

## Focused device log if the failure persists and a Mac is available

Apple's Console guide: https://support.apple.com/en-gb/guide/console/cnsl1012/1.1/mac/15.0

1. Connect and unlock the iPhone. Open Console on the Mac and select that iPhone under Devices.
2. Click Start. Use Console's search/filter to locate StoreKit events; `storekitd` is an initial process filter to try. If it yields no relevant events, inspect nearby StoreKit/App Store messages rather than treating an empty filter as a clean result.
3. Record the local start time, reproduce Restore Purchases once and complete authentication. Stop the capture as soon as the app displays its result.
4. Inspect errors around that precise attempt for domains, numeric codes and nested causes. `StoreKit.unknown` alone is insufficient to assign a cause.
5. Keep raw logs local. Share only the small relevant excerpt with Apple Account details, transaction identifiers, receipts, tokens and URLs redacted. Never commit raw device logs or upload them to a public issue/forum.

Apple's official App Store logging profiles/instructions (requires developer sign-in) are available at https://developer.apple.com/feedback-assistant/profiles-and-logs/ under App Store for iOS/iPadOS. A logging profile is a separate user-controlled diagnostic step; none has been installed.

## Read-only checks already completed

- App Store Connect: all four NON_CONSUMABLE packs and both subscriptions APPROVED.
- Selected build: 16, VALID. Version remains PREPARE_FOR_SUBMISSION.
- Apple Developer System Status: In-App Purchases, Sandbox, Receipt Verification and TestFlight available at the check (page last updated 06:49 BST). Status is not proof that every account or request is healthy.
- No server-side receipt verification exists in this offline-first app; access is granted only from verified StoreKit transactions. Do not bypass verification or mask a failed sync as success.

## Evidence still needed

- Mobile-data result.
- Focused underlying device error, or a supported Apple diagnostic if the error remains opaque.
- A successful signed-device restore retest before App Review submission.
## Windows capture preparation

The owner has Windows only. Apple Mobile Device Service is installed and running. An isolated `pymobiledevice3` environment is installed under ignored DerivedData/RestoreFix/device-tools, following the maintainer's Windows documentation: https://doronz88.github.io/pymobiledevice3/installation/ .

A bounded capture helper is prepared at DerivedData/RestoreFix/capture-device-restore.py. It retains only StoreKit/App Store/PipeBoss matching output, stops after 90 seconds, and writes raw output only under ignored DerivedData/RestoreFix/PrivateDeviceLogs. This is diagnostic tooling, not app code and not part of the signed build. Do not commit raw logs.

The CLI help was verified and non-pairing USB discovery ran successfully, detecting zero connected USB devices. Live-log access has not yet been verified. The owner has been asked to connect and unlock the iPhone. Device trust/pairing, if required, is a separate user action allowing this PC access to the phone; no new pairing has been performed. Do not mount developer images, enable Developer Mode, collect backups or reset account/purchase data for this capture.