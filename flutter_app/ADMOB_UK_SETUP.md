# UK AdMob Setup — RANDA.MKCOOL

This is an owner-side setup guide. Keep bank information, identity documents, tax details, and payment-verification information inside Google's payment systems only. Never commit them to GitHub or put them in the app.

## 1. Create the AdMob app and ad units

Create/sign in to Google AdMob, add the Android app, and create the required Banner and Interstitial ad units. During development, use Google's test ads rather than live ad-unit traffic. The Flutter client currently contains a banner placeholder so production ad code can be added without mixing payout information into application source.

## 2. Complete payments verification and add the UK bank payment method

When the AdMob account reaches Google's applicable thresholds, complete identity/address verification. For GBP accounts, Google's published payment-method selection threshold is £10 and the payment threshold is £60. In AdMob, use Payments > How you get paid > Add payment method, then choose an available electronic bank payment option and enter the bank information directly in Google's payment interface.

## 3. Receive monthly payments

AdMob finalises earnings after the month ends. If the finalised balance meets the £60 GBP payment threshold and there are no payment holds, Google normally issues payment on or around the 21st of the month. Bank-transfer arrival time depends on the payment method and bank.

## Separate Google Play cost

Creating and using AdMob is separate from obtaining wide Android/Google Play distribution. As of September 2026, Google's full Android distribution account requires a one-time US$25 registration fee. Google's limited distribution option is free but is intended for a closed group and is capped at 20 authorised devices. Do not spend this fee automatically under the project's zero-outbound-cash rule.

## Play payments warning

The current paid Aim Sync product is a digital app feature. A Google Play-distributed build cannot simply link users to Stripe unless the app is eligible for, enrolled in, and technically compliant with Google's applicable alternative/external billing programme. The live web/PWA Stripe funnel remains separate and should stay the canonical payment route until the Android store billing route is deliberately approved and implemented.
