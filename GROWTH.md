# PipeBoss AI Growth Priorities

## What Changed

This update adds offline localization infrastructure, a review-gated translation workflow and search-focused listing drafts. The store now compares live monthly/yearly prices in the same currency, shows genuine annual savings, clearly states that both plans provide the same access, shows the current plan and prevents concurrent purchase taps. Unimplemented analytics/cloud benefits and App Review instructions no longer appear as selling points. Cached access is not cleared merely because product prices are still loading; entitlements refresh separately. Daily energy refreshes when the app becomes active.

Level-only job locks now show the actual progression requirement instead of opening a paywall. These changes are hypotheses for better comprehension, trust and purchase conversion. No uplift has been measured and App Store approval is not proof of user demand.

## First Priority: Learning Value

1. Make the first successful job short and satisfying. Test a first-job completion target of under three minutes with real apprentices. Start with the customer problem, not a paywall. Keep the safety disclaimer and do not imply real-world certification.
2. Add a local skills dashboard: diagnosis accuracy, repair accuracy, repeated mistakes and topic mastery. Record job attempts rather than just total XP. This would make a meaningful Pro feature, but it is not implemented by this update.
3. Add spaced practice based on incorrect answers and a daily scenario. Let people revisit mistakes without an immediate paywall. A streak should encourage practice, not punish a missed day.
4. Test progression with new players. If the next useful job is tool-locked, show the tool and the coin path to it. Distinguish level locks from paid locks, and never show a paywall for a job that only needs a higher level.
5. Replace sample leaderboard and placeholder ad behaviour before promoting them. Current rewarded actions grant currency/energy without a real ad network. Do not scale an ad revenue plan until rewards are verified by an actual optional ad completion callback, with updated privacy disclosures.

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
- Ask for a rating after several successful jobs using Apple's native review request. Never reward positive reviews or block unhappy users from reviewing.

## Measurement

Use App Store Connect for impressions, product page views, source/campaign attribution, downloads, subscriptions, proceeds and available retention/crash metrics. Do not treat the old screenshot's tiny sample as a reliable funnel or benchmark.

For future in-app measurement, define events precisely: onboarding completed, first job completed, diagnosis/repair correctness, topic revisited, paywall opened by trigger, verified purchase and restore outcome. Prefer local aggregate learning data initially. Remote analytics would change the current privacy position: review consent, retention, vendor SDK behaviour, privacy policy and App Store disclosures before collecting anything. Never send names, raw answers or free-form content unnecessarily.

Judge acquisition by retained learners and net proceeds per acquired learner, not raw downloads. Evaluate first-job completion, day-1/day-7 returns, paywall-to-verified-purchase conversion, trial-to-paid conversion if a trial exists, renewal, refunds and crashes by version. Definitions and denominators must stay consistent across tests.

## Release Order

1. Finish translation review and iPhone/iPad purchase/layout testing, then release the quality update.
2. Improve onboarding and first-job clarity; establish a baseline over a meaningful sample.
3. Add mistake review/local skills reporting and test retention.
4. Test one contextual paywall or billing-layout variant, leaving prices unchanged initially.
5. Scale only the audience/campaigns whose retained-learner economics work. Expand language markets one at a time.

## References

- Apple product pages and metadata: https://developer.apple.com/app-store/product-page/
- Apple field limits: https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Apple subscription presentation: https://developer.apple.com/app-store/subscriptions/
- Product page optimization: https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview-of-product-page-optimization/
