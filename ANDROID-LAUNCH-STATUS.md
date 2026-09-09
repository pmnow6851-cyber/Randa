# RANDA.MKCOOL Android Launch Status

Date: 2026-09-09

## Launched into official source

The verified Flutter Android client has been merged into the canonical `pmnow6851-cyber/Randa` repository on `main` via PR #11.

Verified before merge:
- Flutter static analysis passed with no issues.
- Android debug APK compiled successfully.
- CI produced the `randa-mkcool-android-debug` artifact.
- Android minimum SDK is 24.
- Android app backup is disabled in the generated build wrapper.
- Paid sensitivity calculation coefficients remain outside the public Flutter client.
- Supabase authentication and paid entitlement restoration are used by the Android client.
- The existing GitHub Pages v5 paid PWA remains the canonical public customer app and its `index.html` was not replaced by the Android merge.

## Distribution boundary

The Android source is official and a working debug APK exists for direct device testing. This is not yet a Google Play production release.

Before public Google Play distribution, complete:
1. Production release signing with an owner-controlled key kept out of the public repository.
2. End-to-end device testing of sign-in, £9.99 paid entitlement restoration, calculation and one-tap copy.
3. Google Play payments-policy compliance for digital features.
4. Production AdMob App ID/ad-unit configuration plus required privacy/consent handling.
5. Store listing disclosures, privacy information and release build checks.

No outbound payment or store registration fee was made as part of this launch step.
