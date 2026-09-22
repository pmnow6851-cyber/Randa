# RANDA.MKCOOL Aim Sync — Flutter Android Client

This folder contains the Android Flutter client for the existing paid RANDA.MKCOOL Aim Sync production system.

## Production architecture

- The public GitHub Pages PWA remains the canonical live customer-facing app until the native app passes release checks and is deliberately published.
- The sensitivity calculation engine remains private in Supabase Edge Functions. Do not copy its method, coefficients, or generated paid outputs into this repository.
- Supabase Auth is used for account sign-in and paid entitlement restoration.
- Stripe checkout and payment verification remain server-side. The native client never contains Stripe secret keys, bank information, service-role keys, or payout details.
- Flutter stores session tokens with `flutter_secure_storage` rather than plain shared preferences.
- The Android wrapper is generated with minimum SDK 24 and Android backup disabled for the app.

## Local Android bootstrap

From this `flutter_app` directory with Flutter installed:

```bash
flutter create --platforms=android --project-name randa_mkcool_aim_sync --org systems.randamkcool .
flutter pub get
```

Then set Android `minSdk` to 24 and set `android:allowBackup="false"` in the main Android manifest before building.

Run:

```bash
flutter analyze
flutter build apk --debug
```

The repository workflow `.github/workflows/flutter-android-check.yml` performs the same checks automatically and uploads a debug APK artifact after a successful build.

## Monetisation guardrail

The Android client follows the same paid-access model as the production system: one verified one-time unlock, with entitlement checked server-side. Do not add advertising, free-user bypasses, alternate checkout providers, or client-side payment secrets to the release build.

Bank details, payout data, signing keys, service-role keys, and payment-provider secrets must remain outside the repository.

## Release rule

Do not replace the canonical live PWA or publish the Android build solely because it compiles. A release still needs device testing, payment/unlock testing, store-policy review, privacy disclosures, signing configuration, and deliberate owner approval.
