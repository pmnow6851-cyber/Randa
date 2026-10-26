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

From this `flutter_app` directory with Flutter 3.47.8 installed:

Flutter 3.47.8 is the minimum patched stable SDK identified in [GHSA-frr6-h895-5pxp](https://github.com/dart-lang/sdk/security/advisories/GHSA-frr6-h895-5pxp) for the Android TLS certificate-validation issue (patched Dart SDK: 3.13.7). Rebuild Android artifacts with the patched SDK; changing this pin alone does not update an installed app. Signing, physical-device verification and owner release approval remain separate gates.

```bash
flutter pub get
flutter analyze
flutter test --dart-define=RANDA_DISTRIBUTION_CHANNEL=google_play
flutter build apk --debug --dart-define=RANDA_DISTRIBUTION_CHANNEL=google_play
flutter build appbundle --release --dart-define=RANDA_DISTRIBUTION_CHANNEL=google_play
```

Do not run `flutter create` as part of a normal build. The Android wrapper is source-controlled and must remain reproducible from the repository.

The repository workflow `.github/workflows/flutter-android-check.yml` verifies the committed Android project, runs analysis, runs the automated tests with the Google Play distribution channel, and builds a debug APK and an unsigned release AAB with that same channel. Use the matching debug APK for physical-device evidence. A debug-APK pass does not replace testing the final signed release delivered by Play.

## Signing and secret boundary

Release signing keys, keystore passwords, Firebase client configuration, service-role keys, payment-provider secrets, bank details and payout information must stay outside the public repository.

The CI release AAB is intentionally not a publishable production artifact until owner-controlled signing is configured securely. Never commit `google-services.json`, keystores, `key.properties`, signing passwords or private keys.

## Monetisation guardrail

The Android client follows the same paid-access model as the production system: one verified one-time unlock, with entitlement checked server-side. Do not add advertising, free-user bypasses, alternate checkout providers, or client-side payment secrets to the release build.

Native builds require an explicit `RANDA_DISTRIBUTION_CHANNEL` at build time. The `direct` value enables the existing server-backed Stripe checkout only for an authorized direct distribution build. The `google_play` and `app_store` values, plus missing or unknown values, block external checkout. There is no native store purchase flow yet; do not publish a store build until that flow and server-verified entitlements are complete.

The app links to the official privacy and support page. Signed-in users can request deletion through the protected `delete-my-account` function after confirmation. Sign-out and completed deletion clear local secure-storage tokens and in-memory paid results.

## Draft session recovery repair (11 October 2026)

HTTP requests and startup secure-storage reads have a ten-second timeout.
Temporary server failures and malformed successful responses keep saved tokens
for retry while hiding paid results. Definitive authentication rejection clears
tokens. A saved refresh token can restore a missing access token. Refreshes share
one in-flight request per session; secure-storage writes are ordered, and stale
responses cannot reinstate a signed-out session. Leaving or resuming the app
clears protected results until a fresh server check succeeds.

The added tests use synthetic accounts and injected HTTP/storage doubles. They
do not verify live payments, backend authorisation or physical Android storage.
Keep this repair in draft PR #54 until those release gates are satisfied.

## Release rule

Do not replace the canonical live PWA or publish the Android build solely because it compiles. A public release still requires owner-controlled production signing, physical-device testing, payment/unlock testing, store-policy review, privacy disclosures and deliberate owner approval.
