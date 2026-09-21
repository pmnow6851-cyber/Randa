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

## Firebase

Firebase Core is included without replacing the existing Supabase authentication, entitlement, payment, or private calculation flow.

After downloading `google-services.json` from the Firebase Console, keep it owner-controlled and place it locally at:

`flutter_app/firebase/google-services.json`

That path is Git-ignored and the repository audit rejects a tracked `google-services.json`. The configuration must contain the Android package `systems.randamkcool.randa_mkcool_aim_sync` or the bootstrap script stops.

Then generate the Android wrapper and apply the Firebase wiring:

```bash
flutter create --platforms=android --project-name randa_mkcool_aim_sync --org systems.randamkcool .
bash configure_firebase_android.sh
flutter pub get
```

The GitHub Android workflow runs the same configurator automatically. For owner-controlled CI testing, store a base64-encoded copy in the encrypted repository secret `FIREBASE_ANDROID_GOOGLE_SERVICES_JSON_B64`; the workflow restores it only for the build and deletes the temporary copies afterward. The release-readiness workflow now fails closed when that secret is missing, so a green Android check proves the real Firebase configuration was supplied and validated. Local startup still handles unavailable Firebase gracefully, and the existing Supabase paid flow remains unchanged.

## AdMob

`main.dart` includes an explicit AdMob banner placeholder only. Keep test ads during development. Add the official Google Mobile Ads Flutter package and production AdMob App ID/ad-unit IDs only after the AdMob app is created and policy requirements are ready.

Do not commit private bank details or account-verification documents. Ad-unit identifiers are app configuration, but payout/bank information belongs only inside the Google payments profile.

## Release rule

Do not replace the canonical live PWA or publish the Android build solely because it compiles. A release still needs device testing, payment/unlock testing, store-policy review, privacy disclosures, signing configuration, and deliberate owner approval.
