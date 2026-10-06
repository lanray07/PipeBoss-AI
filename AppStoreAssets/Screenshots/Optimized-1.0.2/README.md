# Optimized version 1.0.2 screenshots

Twenty images per locale, across fifty locales (1,000 PNGs): four iPhone 6.5-inch, four iPhone 6.7-inch, four iPad 12.9-inch, four Duo outer-display and four Duo inner-display assets.

The first four messages follow a clear sequence: plumbing training, fault diagnosis, plumbing tools, and repair simulation with feedback. Headlines and supporting captions are localized; native app pixels remain English. Designs use large high-contrast headlines, a consistent navy/orange brand treatment, complete current native captures, and a translated educational/interface-language footer. No conversion improvement or search-ranking increase has been measured.

Render from the workspace root with `tools/create_optimized_screenshots.ps1`. `manifest.json` records native source paths, exact upload dimensions and SHA-256 checksums. Native-source provenance is documented in `AppStoreAssets/SourceCaptures/1.0.2/README.md`.

`tools/upload_optimized_screenshots.mjs --apply` replaces the targeted draft version's old and duplicate screenshot assets. It validates all intended local PNGs before mutations, saves old remote asset metadata under `remote-backups`, and keeps legacy images until one replacement finishes processing. A full ten-image set must free one legacy slot first. The original marketing files and native source captures are retained locally.

Without `--apply`, the uploader reads and verifies remote file order, count and processing state. Credentials are supplied through ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_PATH. SCREENSHOT_LOCALES optionally limits the run to comma-separated Apple locale codes. This workflow does not submit or release the app.

Completed on 6 October 2026: all 200 screenshot sets and 1,000 images passed read-only verification, with exact desired order, COMPLETE processing state and zero errors. The Norwegian and Odia Duo processing delays were resolved by retrying those sets. Saved evidence: `AppStoreAssets/ReleaseProof/optimized-screenshot-verification.json`, `optimized-duo-en-GB.png` and `optimized-duo-fr-FR.png`. These assets supersede the earlier illustrated Duo marketing set.
