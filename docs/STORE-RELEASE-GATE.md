# RANDA.MKCOOL Store Release Gate

Status: **STAGED FOR STORE READINESS — DO NOT SUBMIT UNTIL EVERY REQUIRED GATE IS GREEN**

This document covers the native Flutter build for Google Play and Apple App Store. It does not alter the canonical web app or the existing £9.99 Stripe web purchase route.

## Store payment rule

The current mobile client opens an external Stripe checkout. That must **not** be used as the default purchase flow in a Play Store or App Store build for digital functionality.

For store-distributed builds:

- Use the native non-consumable product ID `randa_mkcool_aim_sync_pro`.
- Google Play builds must use Google Play Billing for the in-app digital unlock unless an explicitly eligible Google external-payments programme is deliberately configured.
- Apple builds must use App Store In-App Purchase for the in-app digital unlock unless an applicable Apple entitlement/exception is deliberately configured.
- Existing users may restore access after server-side purchase verification.
- Never put store private keys, signing keys, service-account JSON, App Store API private keys, bank data, or recovery codes in this public repository.

## Shared product behaviour

Product: RANDA.MKCOOL Aim Sync Pro

Type: one-time / non-consumable digital unlock

Store product ID: `randa_mkcool_aim_sync_pro`

Customer receives:

- MP and BR sensitivity profile generation
- Camera, firing and gyroscope output categories
- Base sensitivity and FOV inputs
- Rotation, device, playstyle and gyro inputs
- One-tap config copy
- Account-based restoration after verified purchase

The calculation engine stays server-side.

## Google Play gates

1. Create/verify the Play Console developer account.
2. Generate a full Android Flutter platform project and use application ID `uk.co.randamkcool.aimsync`.
3. Target Android 16 / API 36 or higher for new submissions in the current 2026 policy window.
4. Configure `randa_mkcool_aim_sync_pro` as a one-time in-app product in Play Console.
5. Connect the Google Play Developer API service account to the secure backend. Keep its private key only in backend secrets.
6. Build a signed Android App Bundle (`.aab`) with a private upload key that is never committed.
7. Complete Play Console Data safety, App access, Ads declaration, Content rating, Target audience and account-deletion declarations accurately.
8. Provide the public privacy-policy URL and account-deletion URL.
9. If the developer account is a personal account created after 13 November 2023, complete the required closed test with at least 12 opted-in testers continuously for 14 days before applying for production access.
10. Test purchase, restore, sign-in, calculation, copy-config and account deletion on a physical Android device.

## Apple App Store gates

1. Enrol in the Apple Developer Program and complete identity/payment/tax/banking setup required by Apple.
2. Generate the iOS Flutter platform project and use bundle ID `uk.co.randamkcool.aimsync` (or another bundle ID owned in the Apple account, kept consistent everywhere).
3. Configure `randa_mkcool_aim_sync_pro` as a non-consumable In-App Purchase in App Store Connect.
4. Connect App Store Server API credentials to the secure backend. Keep the `.p8` private key only in backend secrets.
5. Build/archive with an Apple distribution certificate and App Store provisioning profile from Xcode on macOS.
6. Complete App Privacy, Age Rating, Content Rights, pricing/availability and required export-compliance answers accurately.
7. Put the public privacy-policy URL in App Store Connect and inside the app.
8. Because the app creates accounts, provide a clear in-app Delete Account action that initiates deletion of the account and associated data.
9. Give App Review a working review account or clear review instructions that allow the paid functionality and purchase flow to be tested.
10. Test purchase, restore, sign-in, calculation, copy-config and account deletion on a physical iPhone/iPad before submission.

## Required backend secrets

These values belong only in Supabase Edge Function secrets or equivalent secure server configuration:

- `STORE_PRODUCT_ID=randa_mkcool_aim_sync_pro`
- `ANDROID_PACKAGE_NAME=uk.co.randamkcool.aimsync`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_PRIVATE_KEY`
- `IOS_BUNDLE_ID=uk.co.randamkcool.aimsync`
- `APPLE_ISSUER_ID`
- `APPLE_KEY_ID`
- `APPLE_PRIVATE_KEY`

## Privacy/account deletion

Public pages to expose through GitHub Pages:

- `/privacy.html`
- `/account-deletion.html`
- `/support.html`

The native app must also expose Privacy Policy, Support and Delete Account from its account/settings UI.

## Build preparation

From `flutter_app/`, with a current Flutter SDK installed:

```bash
flutter create --platforms=android,ios --org uk.co.randamkcool .
flutter pub get
flutter analyze
flutter test
```

After generation, confirm the Android target API is 36 or higher before Play submission and confirm the iOS deployment target is compatible with the current Flutter `in_app_purchase` package.

## Hard stop conditions

Do not submit while any of these are true:

- External Stripe checkout is still the primary in-app digital purchase route in a store build.
- Native store purchase verification is not working end-to-end.
- A user can create an account but cannot initiate deletion.
- Privacy-policy URL is missing or inaccurate.
- Store listing claims a feature that the submitted binary does not contain.
- Release signing credentials are missing or exposed.
- Android target API is below the current Play requirement.
- Review/test account cannot access the app as reviewers need.
- A production build has not been tested on a physical Android and physical iOS device.

## Zero-spend rule conflict

Public app-store distribution is not a true £0 route. Google Play developer registration has a one-time fee, and Apple Developer Program membership has an annual fee. Keep the web/PWA route as the zero-hosting-cost distribution path if no developer-account spending is allowed.
