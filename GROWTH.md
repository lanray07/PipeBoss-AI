# PipeBoss AI Growth Priorities

## What Changed

This update adds offline localization infrastructure, a review-gated GitHub translation workflow and search-focused listing drafts. Existing Apple API secrets can apply reviewed metadata to an explicitly selected editable version. Translation generation needs a separate provider secret; no credentials ship in the app. Prices and all six product IDs are unchanged.

The app now records attempts locally, schedules mistake review and spaced practice, provides an energy-free daily challenge, and shows learning streaks without missed-day penalties. Free learners get overall accuracy and practice; Pro adds topic breakdowns, answer history, exam-style practice and a shareable learning report. Accuracy uses at most 500 recent attempts, while lifetime counts remain available. These are simulation learning metrics, not professional qualifications.

The store compares live monthly/yearly prices in the same currency, shows genuine annual savings, clearly states that both plans provide the same access, shows the current plan and prevents concurrent purchase taps. Introductory trial copy appears only for an actual eligible StoreKit offer. Packs have content previews, prerequisite details and links to their included content. Unimplemented cloud benefits and App Review instructions no longer appear as selling points. Cached access is not cleared merely because product prices are still loading; entitlements refresh separately. Daily energy refreshes when the app becomes active.

Sample competitors were replaced by earned achievements. Placeholder rewarded-ad actions were removed because no ad network is integrated. Hints use earned coins, with an initial free career hint and Pro access. Owned tools and premium upgrades now have explicit timer or reward effects. A native, score-independent rating request is eligible after sufficient use, with a cooldown. On-device usage counts are never automatically uploaded.

Level-only job locks now show the actual progression requirement instead of opening a paywall. These changes are hypotheses for better comprehension, trust and purchase conversion. No uplift has been measured and App Store approval is not proof of user demand.

## First Priority: Learning Value

1. Make the first successful job short and satisfying. Test a first-job completion target of under three minutes with real apprentices. Start with the customer problem, not a paywall. Keep the safety disclaimer and do not imply real-world certification.
2. Test the implemented skills dashboard with apprentices: do topic accuracy, answer history and review queues help learners decide what to practice next? Avoid claiming mastery from a small number of answers.
3. Test the implemented spaced practice and daily challenge. Wrong answers remain due; correct reviews are scheduled at one, three, seven and fourteen days. Practice has no energy cost and cannot farm career XP or coins.
4. Test progression with new players. If the next useful job is tool-locked, show the tool and the coin path to it. Distinguish level locks from paid locks, and never show a paywall for a job that only needs a higher level.
5. Retain honest achievements instead of invented competition. If optional rewarded ads are added later, grant rewards only from a verified ad completion callback and update privacy disclosures first. Never interrupt learning with forced ads.

## Second Priority: Purchase Value

- Keep the useful free apprentice career. Show a contextual Pro offer after a successful job or when a player selects genuinely premium content, rather than interrupting onboarding or a repair.
- Test a yearly emphasis against a neutral billing selector. Always show the full annual amount prominently. Savings must come from current StoreKit prices, not a hard-coded percentage.
- Do not change pricing and paywall presentation simultaneously. Start from the existing local prices; compare paid conversion, refunds and renewals, not just first purchases.
- Introduce a trial only after configuring an actual introductory offer in App Store Connect and checking StoreKit eligibility. Never display a promised free trial to an ineligible customer.
- Make packs visibly useful: content preview, number of additional jobs, prerequisite levels/tools and a route to the unlocked content after purchase. Pro and pack overlap should be explained honestly; avoid selling a pack to an owner who already has its value through Pro without a clear reason.
- Add recurring Pro value through new scenarios, exam practice and useful learning analytics before charging more. Cloud sync and team reporting need real implementation before appearing as benefits.
- Pilot company/trade-school training with a few instructors. Ask what progress reports and instructor controls they need before building a B2B product. Do not bypass platform payment rules or call the simulation a qualification.

## Third Priority: Acquisition

- Use the English listing draft first. App name/subtitle/keywords target relevant App Store searches; the description explains the value and can support web search. Keyword stuffing and repeated irrelevant terms are not a strategy.
- Localize the product experience, safety content and StoreKit descriptions before running ads in a new language. Spanish is currently a pilot, not a finished localization.
- Make the first three screenshots communicate a customer problem, a diagnosis decision and a learning result using real gameplay. Create separate assets for apprentices, DIY learners and training companies.
- Use custom product pages and campaign links to connect each audience to matching screenshots. Test one asset variable at a time with product page optimization when there is enough traffic to draw a reliable conclusion.
- Share short real-job diagnosis challenges with apprenticeship programmes and trade creators. Invite viewers to try the free scenario, and label it clearly as a simulation. No guaranteed virality or guaranteed installation volume.
- The implemented native rating request requires at least five career attempts and learning on two separate days, with a 90-day cooldown and at most three requests per year. It does not filter by score, payment or satisfaction. Apple controls whether a prompt actually appears. Never reward positive reviews or block unhappy users from reviewing.

## Measurement

Use App Store Connect for impressions, product page views, source/campaign attribution, downloads, subscriptions, proceeds and available retention/crash metrics. Do not treat the old screenshot's tiny sample as a reliable funnel or benchmark.

The app records controlled local counters for onboarding, career/practice completion, store triggers, verified purchases and successful restore operations. Attempt history supplies diagnosis/repair accuracy and topic review data. These counters are useful for an individual learner, not a population conversion funnel. Remote analytics would change the current privacy position: review consent, retention, vendor SDK behaviour, privacy policy and App Store disclosures before collecting anything. Never send names, raw answers or free-form content unnecessarily.

Judge acquisition by retained learners and net proceeds per acquired learner, not raw downloads. Evaluate first-job completion, day-1/day-7 returns, paywall-to-verified-purchase conversion, trial-to-paid conversion if a trial exists, renewal, refunds and crashes by version. Definitions and denominators must stay consistent across tests.

## Release Order

1. Finish translation review and iPhone/iPad purchase/layout testing, then release the quality update.
2. Validate the new onboarding, first-job timing, practice and pack access on real devices; establish a baseline over a meaningful sample.
3. Measure whether the new mistake review and local skills reporting improve retention.
4. Test one contextual paywall or billing-layout variant, leaving prices unchanged.
5. Scale only the audience/campaigns whose retained-learner economics work. Expand language markets one at a time.

## References

- Apple product pages and metadata: https://developer.apple.com/app-store/product-page/
- Apple field limits: https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Apple subscription presentation: https://developer.apple.com/app-store/subscriptions/
- Product page optimization: https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview-of-product-page-optimization/
