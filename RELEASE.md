# PipeBoss AI 1.0.2 Release

The live version is 1.0.1 (14). This update uses 1.0.2 (15); verify App Store Connect before any upload. Existing product IDs, Apple price schedules and local StoreKit price fixtures remain unchanged.

## Release Gates

- Pass current-commit iOS CI: content checks, Debug Simulator and Release device compilation, nonblank iPhone/iPad screenshots and StoreKit integration tests on both device families.
- Inspect the native screens, including the result view. Simulator fixtures are Debug-only and must not be enabled in a signed Release build.
- Merge PR #1 only after those checks pass. Run `ios-testflight.yml` from the merged commit with build number `15` and upload enabled.
- Install the processed signed build through TestFlight. Confirm both subscriptions, four packs, cancellation, restore, relaunch access, Pro expiry and offline progress where applicable. StoreKitTest uses local fixture products and cannot verify Apple's real product catalogue, agreements or sandbox accounts.
- Keep machine-generated translations and non-English listing drafts unpublished until language and plumbing-safety review. The Spanish starter is a partial pilot, not a complete new market release.
- Apply the reviewed English metadata from `AppStoreAssets/Metadata/localizations.json` only to the editable new version. Release and beta copy are in `AppStoreAssets/Metadata/release-1.0.2.json`; `releaseReady` stays false until all gates are evidenced.
- Upload visually reviewed screenshots from the current commit. Attach the tested build and accurate reviewer steps. Do not claim unperformed tests in review notes.

## Testing

`PipeBossAITests/PurchaseIntegrationTests.swift` exercises real StoreKit APIs against the local test configuration. It covers loading all six products, fixture price stability, monthly/yearly purchases and expiry, all four pack unlocks and refunds, restored access after recreating the purchase manager, and failed purchases leaving neither entitlement nor a busy state.

`tools/test-storekit.sh` runs this suite sequentially on an iPhone and iPad simulator. CI uploads logs and `.xcresult` evidence. Local simulation is separate from signed-build sandbox QA; neither a compile nor previous App Store approval establishes that the new build's purchases work.

## Windows Workflow

GitHub Actions supplies macOS and Xcode. Signing keys stay in GitHub repository secrets; do not download or commit them. TestFlight installation and the native sandbox purchase UI still require an iPhone or iPad. If hosted runners are unavailable, keep the release draft and wait for verified build results instead of submitting an older build.

## Public Legal Pages

The app repository is private. Do not use its file URLs in the app or public listing. Only the privacy and terms documents are published separately:

- Privacy: https://gist.github.com/lanray07/64ca0d681a517c35b42bb0a5819e58a3
- Terms: https://gist.github.com/lanray07/c1cd47ad4c7b598b9067b2c3f37091c9
- Support: https://gist.github.com/lanray07/7812238839aa8f8fbf4ea23d8f18b4c6

Update those documents with `gh gist edit <id> PRIVACY.md`, `gh gist edit <id> TERMS.md` or `gh gist edit <id> SUPPORT.md` when the matching source changes. Verify the public pages without GitHub authentication before submission. The Apple standard EULA remains linked in the listing description. The support page replaces the inaccessible private repository issue URL; the optional marketing URL is blank.
