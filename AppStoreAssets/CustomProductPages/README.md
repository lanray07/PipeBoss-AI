# Localized custom product pages

Verified on 8 October 2026: all three pages have 50 localizations, 15 screenshot placements per localization (2,250 total), and no verification errors. All remain drafts. See `report.json` for the complete verification record.

- [Apprentice Plumbing Training in App Store Connect](https://appstoreconnect.apple.com/apps/6767889535/distribution/productpages/ea555748-77dc-4c6d-8e10-d0286807795e)
- [Plumbing Fault Diagnosis in App Store Connect](https://appstoreconnect.apple.com/apps/6767889535/distribution/productpages/f2035a62-ecd6-4883-a506-19dc5ca3558b)
- [Plumbing Tools and Heating in App Store Connect](https://appstoreconnect.apple.com/apps/6767889535/distribution/productpages/2ff33b9e-419f-4319-8332-cd039663065b)

Three draft pages use existing, complete native app captures with localized marketing captions. No new app UI or features are fabricated. Screenshots disclose that the pictured interface is English and the app is an educational simulation.

| Page | Lead screenshot | Narrative order | Approved English search keywords |
| --- | --- | --- | --- |
| Apprentice Plumbing Training | Plumbing training | Training → diagnosis → repair feedback | apprentice, trade, training, quiz |
| Plumbing Fault Diagnosis | Fault diagnosis | Diagnosis → repair feedback → tools | plumbing, plumber, drain, DIY |
| Plumbing Tools and Heating | Plumbing tools | Tools → diagnosis → repair feedback | tools, pipe, heating, boiler |

Each page targets all 50 App Store locales already present in the editable 1.0.2 listing. Each localization has three screenshots for 6.5-inch iPhone, 6.7-inch iPhone and 12.9-inch iPad, plus six iPhone Duo screenshots covering its inner and outer displays. A text-free header is reused where available on the source listing. The source images remain unchanged in Apple's Asset Library; only new placements and their display order are created.

Promotional text reuses the existing machine-translated caption set in `tools/duo-captions.json`; English variants use theme-specific copy. It fits Apple's 170-character limit and includes the educational/English-interface disclosure. Translations have not had native-speaker review. Optimization here means matching the first screenshot, copy and eligible search terms to a specific intent; no measured conversion or search-volume improvement is claimed.

Apple permits assigning only keywords from the latest approved listing for the corresponding localization. The workflow selects a distinct set for each page where eligible. Localizations without matching approved keywords retain localized creative and promotional text; their pending keyword eligibility is recorded rather than inventing or silently inserting English keywords. Approving localized default-listing keywords is a separate release task.

## Workflow and scope

`tools/custom_product_pages.mjs` uses the repository's existing App Store Connect API secrets in GitHub Actions. It never exports credentials. With `CPP_APPLY=true`, it creates or resumes the named draft pages, checks source screenshot coverage, creates reusable asset placements, orders them, and reads back the placement IDs to verify exact source image identity and ordering. Only extra placements on these named editable drafts are removed; library images and default product-page placements are preserved.

Without `CPP_APPLY=true`, it inventories pages only. `CPP_LOCALES` optionally limits a pilot run. The workflow cannot submit to App Review, release the app, or change pricing. Pages remain in Prepare for Submission; their generated URLs are not a claim that Apple has approved them.

Push-triggered runs only inspect existing pages. Manual runs default to inspection; the explicit `apply` input enables draft changes, and `locales` can limit them to selected locale codes. The successful full creation run was GitHub Actions run 37764862477.

`report.json` records live page IDs, URLs, localized copy, assigned keywords, screenshots and verification. The App Store app is 6767889535, and the source version resource is fe8bb46d-7337-47c4-8fb1-d224ddce21f1.

Apple references:

- https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions
- https://developer.apple.com/documentation/appstoreconnectapi/placing-assets-on-your-app-store-surfaces
