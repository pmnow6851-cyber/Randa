# RANDA.MKCOOL Android — Google Play Release Gate

Status: **NOT YET APPROVED FOR PUBLIC PLAY RELEASE**

This checklist applies only to the Flutter Android client. It must not alter the canonical GitHub Pages app, the £9.99 one-time Stripe route, payout routing, entitlement rules, production secrets, or the private Aim Sync calculation logic.

## Already verified

- Flutter Android client source is in the canonical `pmnow6851-cyber/Randa` repository.
- Flutter static analysis passes in CI.
- Android debug APK builds in CI.
- Minimum Android SDK is 24.
- Android app backup is disabled in the generated wrapper.
- Session tokens use secure storage.
- Supabase authentication and paid-entitlement restoration remain server-backed.
- Sensitivity calculation coefficients remain outside the public Flutter client.
- The GitHub Pages paid PWA remains the canonical live customer app.
- The production offer remains one £9.99 GBP one-time payment route.
- Android signing files are excluded by `.gitignore` (`*.jks`, `*.keystore`, `key.properties`).

## Owner actions required before Play release

### 1. Release signing

Create the upload/release signing key under owner control. Keep the keystore, passwords and `key.properties` out of GitHub. Configure Play App Signing and build the final signed AAB only in a trusted owner environment or an approved secret-backed CI environment.

### 2. Real-device test

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
- cancelled checkout/payment-return behaviour outside any Play consumption-only build

Do not change production price, payout routing, entitlement policy, or calculation logic merely to make a test pass.

### 3. Google Play billing policy decision

Before uploading a public Play build, choose and document one compliant path:

- a consumption-only Play build that restores access already purchased outside the app and contains no external purchase CTA; or
- a Google-approved billing-choice / alternative-billing implementation that meets the programme requirements applicable to the UK.

Do not silently replace or duplicate the canonical £9.99 web payment route.

### 4. AdMob production setup

Owner must create the AdMob app and production ad units, complete any required identity/payment verification, and keep bank/payment profile information inside Google only. Development must continue to use test ads until production IDs and consent configuration are ready.

### 5. Privacy and consent

Before personalised ads are served in the UK/EEA/Switzerland, configure a Google-certified CMP/TCF-compatible consent flow in AdMob and provide a privacy-options path where required.

Publish an app-specific privacy policy covering at minimum account/authentication data, Supabase processing, Stripe/payment processing, AdMob advertising data, retention, user rights, and contact details.

### 6. Account deletion

Because the app can create user accounts, provide:

- a readily discoverable in-app path to request account deletion; and
- an external web resource for deletion requests, entered in Play Console.

Deletion handling must remove the account and associated user data except data that must legally or operationally be retained, with any retention disclosed in the privacy policy.

### 7. Play Console disclosures

Complete and verify:

- Data safety
- Contains ads
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

Public Play release requires deliberate owner approval after every applicable gate above is green. A successful debug APK or CI build is not permission to publish.
