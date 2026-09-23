# RANDA.MKCOOL Aim Sync — Flutter Android Client

This folder contains the Android Flutter client for the existing paid RANDA.MKCOOL Aim Sync production system.

## Production architecture

- The public GitHub Pages PWA remains the canonical live customer-facing app until the native app passes release checks and is deliberately published.
- The Android platform project is committed under `flutter_app/android/`; CI must build that committed source and must not generate a disposable wrapper.
- The sensitivity calculation engine remains private in Supabase Edge Functions. Do not copy its method, coefficients, or generated paid outputs into this repository.
- Supabase Auth is used for account sign-in and paid entitlement restoration.
- Stripe checkout and payment verification remain server-side. The native client never contains Stripe secret keys, bank information, service-role keys, or payout details.
- Flutter stores session tokens with `flutter_secure_storage` rather than plain shared preferences.
- Android policy is locked to application ID `systems.randamkcool.randa_mkcool_aim_sync`, minimum SDK 24, target/compile SDK 36, backup disabled and cleartext traffic disabled.

## Local Android build

From this `flutter_app` directory with Flutter 3.47.2 installed:

```bash
flutter pub get
flutter analyze
flutter build apk --debug
flutter build appbundle --release
```

Do not run `flutter create` as part of a normal build. The Android wrapper is source-controlled and must remain reproducible from the repository.

The repository workflow `.github/workflows/flutter-android-check.yml` verifies the committed Android project, runs analysis, builds a debug APK, and builds a release AAB validation artifact.

## Signing and secret boundary

Release signing keys, keystore passwords, Firebase client configuration, service-role keys, payment-provider secrets, bank details and payout information must stay outside the public repository.

The CI release AAB is intentionally not a publishable production artifact until owner-controlled signing is configured securely. Never commit `google-services.json`, keystores, `key.properties`, signing passwords or private keys.

## Monetisation guardrail

The Android client follows the same paid-access model as the production system: one verified one-time unlock, with entitlement checked server-side. Do not add advertising, free-user bypasses, alternate checkout providers, or client-side payment secrets to the release build.

## Release rule

Do not replace the canonical live PWA or publish the Android build solely because it compiles. A public release still requires owner-controlled production signing, physical-device testing, payment/unlock testing, store-policy review, privacy disclosures and deliberate owner approval.
