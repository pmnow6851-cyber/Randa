# RANDA.MKCOOL Android + iOS Store Release Gate

Status: AMBER — do not submit yet.

This gate protects the live paid web app while the native Flutter client is prepared for Google Play and the Apple App Store.

## Backend status

- `verify-store-purchase` is deployed and authenticated.
- `delete-my-account` is deployed and authenticated.
- The paid Aim Sync calculation endpoint now accepts only verified active entitlements from one of these providers:
  - Stripe, with a valid PaymentIntent reference
  - Google Play, with a verified Google order or token-derived reference
  - Apple App Store, with a verified App Store transaction reference
- A unique database index prevents the same provider purchase reference from being claimed by more than one account.
- Store verification remains fail-closed until the real Google Play and Apple verification credentials and identifiers are configured.
- Existing live Stripe web access remains supported and unchanged.

## Submission blockers

The native app must remain blocked from store submission until all items below are green:

1. Native purchase UI is wired to `in_app_purchase`.
2. Restore Purchases works on both Android and iOS.
3. Completed native purchases are sent to `verify-store-purchase` and the returned entitlement unlocks Aim Sync.
4. Google Play product ID and Apple product ID match the backend `STORE_PRODUCT_ID` value.
5. Google Play service-account verification credentials are configured only in Supabase secrets, never in the client or repository.
6. Apple App Store verification credentials are configured only in Supabase secrets, never in the client or repository.
7. An in-app Delete Account action calls `delete-my-account` after explicit user confirmation.
8. Android and iOS platform folders, package/bundle identifiers, release signing, icons and launch assets are complete.
9. Android release build targets the current Play requirement and passes release testing.
10. iOS archive passes signing, entitlement and TestFlight checks.
11. Privacy Policy, account-deletion URL, support URL and data declarations match actual behavior.
12. Store screenshots and copy do not claim unsupported results or affiliation with Activision, Call of Duty, Tencent or TiMi.
13. Physical-device purchase, restore, sign-in, sign-out, delete-account and entitlement tests pass.
14. No off-store Stripe purchase button is shown inside a store-distributed binary where store rules require native billing for the digital unlock.

## Live web protection

Do not replace or break the canonical live web route while this gate is amber. The existing paid web flow continues to use the canonical £9.99 Stripe offer and server-side entitlement checks.

## Release decision

GREEN only when every submission blocker above has been tested successfully. Until then, keep the store-readiness pull request in Draft and do not merge it into production merely to accelerate submission.
