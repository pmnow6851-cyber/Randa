# RANDA.MKCOOL Android Launch Status

Date: 2026-09-23

## Android source state

The Flutter client source is official in the canonical `pmnow6851-cyber/Randa` repository. The Android platform project is now maintained as committed source under `flutter_app/android/` instead of being generated only inside GitHub Actions.

Release identity and security policy:
- Application ID and namespace: `systems.randamkcool.randa_mkcool_aim_sync`
- Minimum SDK: 24
- Compile SDK: 36
- Target SDK: 36
- Android backup disabled
- Cleartext network traffic disabled
- Internet permission present for the authenticated network client
- Release source does not use debug signing
- Signing keys, Firebase configuration, bank details and private payment credentials are excluded from source control

## CI validation

The Android workflow now fails if the committed Android project is missing. It no longer runs `flutter create` to manufacture an ephemeral wrapper.

CI validates:
- committed Android project structure;
- package identity and SDK policy;
- secret/signing-file exclusions;
- Flutter static analysis;
- debug APK build;
- release AAB build from the committed Android source.

The release AAB produced by CI is a validation artifact and is not for publishing until owner-controlled signing is configured.

## Distribution boundary

The existing GitHub Pages paid PWA remains the canonical public customer application and must remain untouched by Android build work.

Before Google Play production distribution:
1. Configure owner-controlled Play App Signing/upload signing without committing private key material.
2. Complete physical-device testing for sign-in, paid entitlement restoration, calculation and one-tap copy.
3. Complete Google Play billing/policy requirements for the submitted paid digital functionality.
4. Complete store privacy, data-safety, account-deletion and listing declarations.
5. Produce and verify the deliberately approved signed production AAB.

No advertising, free-access bypass or alternate payment route is part of this Android release path.
