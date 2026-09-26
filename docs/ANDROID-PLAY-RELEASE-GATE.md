# RANDA.MKCOOL Android — Google Play Release Gate

Status: **NOT YET APPROVED FOR PUBLIC PLAY RELEASE**

This checklist applies only to the Flutter Android client. It must not alter the canonical GitHub Pages app, the £9.99 one-time Stripe route, payout routing, entitlement rules, production secrets, or the private Aim Sync calculation logic.

## Zero-spend distribution gate

The current project rule is **£0 discretionary outbound spend**.

As verified against Google's documentation on 26 September 2026:
- a [Play Console developer account](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en) requires a one-time **US$25 registration fee** if a suitable account does not already exist
- [Android Developer Console limited distribution](https://developer.android.com/developer-verification/guides/limited-distribution) is free and permits sharing with up to 20 authorised devices **outside Google Play**; Google describes it for students and hobbyists, so do not assume it fits this commercial paid product
- prior business email verification does not establish whether a Play developer account is paid and eligible

Therefore:
- do **not** pay a developer registration fee automatically
- keep the GitHub Pages/PWA product as the canonical public customer route
- use free local/direct device testing; consider limited distribution only if the provider's account eligibility and device limits genuinely fit
- public Play distribution remains blocked unless the owner confirms an eligible existing Play developer account or explicitly changes the zero-spend rule
- never treat Play Console email verification alone as proof of registration or release approval

## Already verified

- Flutter Android client source is in the canonical `pmnow6851-cyber/Randa` repository.
- Flutter static analysis passes in CI.
- Android debug APK builds in CI.
- Minimum Android SDK is 24.
- Android app backup is disabled in the committed Android wrapper.
- Session tokens use secure storage.
- Supabase authentication and paid-entitlement restoration remain server-backed.
- The Flutter and PWA clients now provide an account-deletion request path, with a public deletion page.
- Sensitivity calculation coefficients remain outside the public Flutter client.
- The GitHub Pages paid PWA remains the canonical live customer app.
- The production offer remains one £9.99 GBP one-time payment route.
- Android signing files are excluded by `.gitignore` (`*.jks`, `*.keystore`, `key.properties`).
- CI targets Android 16 / API 36 for the Android release-readiness build path.

## Owner actions required before any public Play release

### 1. Resolve distribution-plan and cost gate

Before any public/wide Play distribution:
- verify whether the owner already has a paid/eligible full-distribution developer account; or
- obtain explicit owner approval before incurring the one-time registration fee.

Under the current zero-spend rule, do not pay the registration fee. Android Developer Console limited distribution is outside Play and must not be represented as a public store launch or assumed suitable for this paid product.

### 2. Release signing

Create the upload/release signing key under owner control. Keep the keystore, passwords and `key.properties` out of GitHub. Configure Play App Signing and build the final signed AAB only in a trusted owner environment or an approved secret-backed CI environment.

### 3. Real-device test

Test the release candidate on a physical Android device, including:

- fresh install
- account creation and email confirmation where applicable
- sign-in and sign-out
- session restoration after app restart
- existing £9.99 entitlement restoration
- calculator inputs and edge values
- MP and BR output rendering
- One-Tap Copy Config
- network loss and recovery
- cancelled purchase and entitlement restoration in the approved distribution channel; verify the direct Stripe return only in a direct-distribution build

Do not change production price, payout routing, entitlement policy, or calculation logic merely to make a test pass.

### 4. Google Play billing policy decision

Before uploading a public Play build, choose and document one compliant path for the regions where the app will be distributed.

Do not silently replace or duplicate the canonical £9.99 web payment route. Do not assume an external purchase CTA is Play-compliant merely because it works technically; re-check the current Google Play Payments policy before public distribution.

### 5. Privacy and data handling

Publish and verify an app-specific privacy policy covering account/authentication data, Supabase processing, the web Stripe payment route, any approved store billing route, retention, user rights, and a business support contact. Ensure the Data safety form reflects the actual Android build and its SDKs.

The paid-only release has no advertising or AdMob requirement. Do not create production ad units for this release.

### 6. Account deletion

Because the app can create user accounts, provide:

- a readily discoverable in-app path to request account deletion; and
- an external web resource for deletion requests, entered in Play Console (the published `/Randa/delete-account.html` page).

Deletion handling must remove the account and associated user data except data that must legally or operationally be retained, with any retention disclosed in the privacy policy.

### 7. Play Console disclosures

Complete and verify:

- Data safety
- Contains ads: declare **No** for the ad-free release build, and verify the submitted binary matches
- App access / reviewer instructions
- Target audience and content
- Content rating
- Privacy policy URL
- Account deletion URL
- Store listing assets and support contact

### 8. Technical release checks

- Target Android 16 / API 36 or higher for new Play submissions after 31 August 2026.
- Build an Android App Bundle (`.aab`).
- Confirm final application ID/package identity before first production upload.
- Verify versionCode/versionName are correct and incremented for updates.
- Run final `flutter analyze` and release build checks.

## Release decision

Public Play release requires deliberate owner approval after every applicable gate above is green **and** after the distribution-cost gate is resolved without violating the current money rule.

A successful debug APK/AAB or Play Console verification email is not permission to publish or spend money.
