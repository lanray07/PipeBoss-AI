# Localization Workflow

## Current Scope

- English source: `PipeBossAI/Content/AppContent.swift` and the real Swift data models.
- Native offline catalogue: `PipeBossAI/Content/Localizable.xcstrings`.
- Language selection: Onboarding and Settings > Language, persisted independently of game progress.
- Spanish pilot: partial UI, tool descriptions and first-job translations. Run the coverage validator for current totals; new content falls back to English. It is not a complete Spanish release.
- No translation API, API key, player name or saved progress is sent from the iOS app.
- iOS 17 remains supported. No language-model download is required at runtime.

The Spanish starter is hand-authored. Have a native speaker and qualified plumbing educator check terminology, safety, answer equivalence and layouts before publishing it as supported language content. Language translation does not adapt plumbing regulations to another country.

## Export Content

From the repository root, on Windows or macOS:

```powershell
swiftc PipeBossAI/Core/Models.swift PipeBossAI/Content/AppContent.swift tools/localization/main.swift -o tools/localization/export-content.exe
./tools/localization/export-content.exe tools/localization/source.json
python tools/localization/localize.py sync
```

On macOS, use `python3`; the exporter can be named `/tmp/export-content` without `.exe`.

The exporter reflects actual models, not source-code regular expressions. It excludes IDs, correct-answer references, SF Symbols, URLs and example prices. Context comments identify where each phrase is used. Changing an English phrase creates a new catalogue key and removes the old one on sync; previous translations are not silently applied to changed content.

## Auto-Translate

Use a DeepL API Free or Pro credential named `DEEPL_AUTH_KEY` in **GitHub repository Actions secrets**. Never put a credential in the app, repository or a chat message. The existing Apple signing/API secrets cannot generate translations. An API subscription may incur charges; dry-run first. No local credential setup is needed.

```powershell
python tools/localization/localize.py translate es --dry-run
python tools/localization/localize.py translate es
python tools/localization/localize.py translate fr
python tools/localization/localize.py translate de
python tools/localization/localize.py translate pt-BR
```

Optionally pass `--glossary-id YOUR_DEEPL_GLOSSARY_ID` for a matching English/target-language trade terminology glossary. Drafts contain source hashes and explicit review flags. Named placeholders, PipeBoss branding and legal URLs are protected and checked after translation. Each completed batch is cached; interrupted runs can resume. Timeouts and retries are bounded.

The `Generate translation drafts` GitHub workflow defaults to a cost-estimate dry run when dispatched manually. On main-branch content updates it generates cached drafts for Spanish, French, German and Brazilian Portuguese if the translation secret exists. If the secret is missing, it generates estimates and an explicit notice only. It uploads drafts as artifacts, never ships unreviewed content, never submits an app, and never changes prices. Only public source copy is sent to the provider.

## Review And Publish

1. Review `tools/localization/drafts/<locale>.json`. Correct translations as necessary.
2. Set `reviewed` to `true` only for individually checked entries.
3. Have a qualified educator check safety warnings, questions, repair choices, learning tips and mentor hints. Set `safetyReviewed` only after that review. Preserve wrong answers as wrong answers, without leaking the correct choice into distractors.
4. Publish the reviewed entries and validate coverage:

```powershell
python tools/localization/localize.py publish tools/localization/drafts/es.json
python tools/localization/localize.py validate
python tools/localization/localize.py validate --release
```

`--release` deliberately fails for incomplete languages. The current Spanish pilot fails that completeness gate. Normal development validation permits English fallback; do not mistake that for a fully translated release.

For additional languages, add the bundled language code/native name to `LocalizationPreferences`, its allowed selection list, and the Xcode project's `knownRegions`. Only expose the language after full content and layout review. The native catalogue then produces its `.lproj` bundle at build time. Do not translate saved IDs or use translated strings in game decision comparisons.

## Store Metadata

`AppStoreAssets/Metadata/localizations.json` contains draft English, Spanish, French, German and Brazilian Portuguese listing copy, plus web page title/meta description suggestions. English is ready for editorial review; the other locales are marked `releaseReady: false` until language support is complete. Nothing is uploaded automatically.

The `Prepare or apply reviewed App Store localizations` workflow uses the existing `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_API_ISSUER_ID`, and `APP_STORE_CONNECT_API_KEY_BASE64` Actions secrets. The default run creates a metadata plan without contacting Apple. Applying requires explicit editable version/app-info resource IDs and `apply: true`. It accepts only PipeBoss AI resources in editable states, skips unreviewed languages, and has no pricing, purchase, submission, or release API operations. It does not create a new version automatically.

```powershell
python tools/localization/validate_metadata.py
python -m unittest discover -s tools/localization -p 'test_*.py'
```

The validator checks 30-character names/subtitles, 170-character promotional text, 4,000-character descriptions, the stricter 100-UTF-8-byte keyword limit and required legal links. These are relevant keyword hypotheses, not claims of measured search volume or ranking guarantees. App Store metadata, StoreKit product display names/descriptions and translated screenshots must be localized separately in App Store Connect.

## Device Verification

- Run the macOS iOS CI build; Windows cannot compile SwiftUI/StoreKit.
- Test language switching with existing progress, purchased packs and a running job on another tab. No career reset should occur.
- Test fresh Spanish-device onboarding, long labels, Dynamic Type, VoiceOver and narrow iPhone/iPad layouts.
- Complete every translated diagnosis/repair path and compare the same IDs/rewards with English.
- In TestFlight sandbox, test both subscriptions, each pack, cancellation, restore, expiry and refunds. StoreKit prices follow the storefront, not the app-language picker.
- Test offline reopening, English fallback, store-load failure/retry and daily energy refresh after returning to the app.
- Before release, remove the Spanish beta label only once full coverage and professional content review pass.
