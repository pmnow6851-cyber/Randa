# RANDA.MKCOOL Cross-Platform AI App Factory

Status: architecture baseline  
Policy: RANDA-AI-POLICY.md applies to every app produced from this pattern.

## Objective

Build RANDA.MKCOOL apps from one Flutter/Dart codebase wherever practical, while keeping payments, AI credentials, private data, admin logic, and proprietary business logic off the client.

Target surfaces:

- Android
- iOS / iPadOS
- Web / PWA
- Google AI compatible through a server-side provider adapter
- Meta Llama compatible through a server-side or approved on-device provider adapter
- Future AI providers through the same adapter boundary

Compatibility does not mean every provider must be enabled in every release. Providers stay disabled until they are required, lawful, privacy-reviewed, cost-reviewed, and configured without client secrets.

## Non-negotiable architecture

CLIENT APP
↓
RANDA AUTHENTICATION
↓
RANDA SERVER-SIDE GATEWAY
↓
POLICY / ENTITLEMENT / RATE LIMIT
↓
OPTIONAL AI PROVIDER
↓
SANITISED RESPONSE

Never place paid or privileged AI provider keys in Flutter, JavaScript, public GitHub, app bundles, screenshots, or store metadata.

## Distribution channels

### Direct web / PWA

The direct RANDA.MKCOOL web path may use the approved server-created Stripe checkout flow.

### Google Play

A Google Play release must use the store-compliant purchase flow selected for that release and region. Do not ship the direct Stripe button accidentally.

Build with:

```bash
flutter build appbundle --release \
  --dart-define=RANDA_DISTRIBUTION_CHANNEL=google_play
```

The backend already has a server-side purchase-verification boundary. Store credentials remain server-side only.

### Apple App Store

An App Store release must use the approved App Store purchase flow. Do not ship the direct Stripe button accidentally.

Build with:

```bash
flutter build ipa --release \
  --dart-define=RANDA_DISTRIBUTION_CHANNEL=app_store
```

The iOS platform wrapper, signing, StoreKit product configuration, privacy declarations, device testing, and App Review requirements must be completed before release.

### Direct / non-store build

```bash
flutter build apk --release \
  --dart-define=RANDA_DISTRIBUTION_CHANNEL=direct
```

Direct builds may use the existing authenticated server-created Stripe checkout path.

## AI provider rule

AI is an optional capability, not a dependency of every RANDA.MKCOOL app.

Every AI-enabled app should call a RANDA server-side gateway rather than a vendor API directly from the client.

The gateway is responsible for:

- authentication
- entitlement checks
- provider selection
- request validation
- abuse controls
- cost controls
- privacy filtering
- model/version allowlisting
- output-size limits
- logging without secrets
- graceful fallback

## Google AI

Gemini compatibility should be implemented behind the RANDA server gateway. A free tier may be used only while it remains suitable for the app and within the zero-spend policy. Never silently upgrade to paid billing.

## Meta / Llama

Llama compatibility should use an approved server endpoint, hosting partner, or appropriately licensed on-device model. Model licence, acceptable-use requirements, download size, device capability, and hosting cost must be reviewed before enabling a model.

"Meta AI compatible" must not be represented as an official Meta partnership or endorsement.

## Free-first rule

Building and testing can use free/open-source tooling wherever practical.

Publishing to commercial app stores is not assumed to be free. Store account fees and transaction/service fees are external platform costs and require owner approval before any spend.

## New app template checklist

Every new RANDA.MKCOOL app starts with:

- Flutter/Dart
- one canonical repository
- Android + iOS + web design target
- privacy-first permissions
- no embedded privileged secrets
- server-side payment verification
- server-side AI gateway if AI is used
- store-specific distribution policy
- account deletion support when accounts exist
- truthful privacy disclosures
- dependency and secret scanning
- CI build/analyse/test gates
- rollback path
- no paid service activation without approval

## Revenue rule

Cash generation is an objective, never a guarantee.

Revenue features must be:

- lawful
- truthful
- auditable
- owner-controlled
- store-policy compliant
- privacy-safe
- free-first to operate
- incapable of silently spending money

## Definition of ready

An app is not "store ready" merely because it compiles.

Ready means:

- platform wrapper exists
- signing is owner-controlled
- physical-device tests pass
- billing path is compliant and verified
- account deletion works where required
- privacy disclosures match production
- AI data flow is documented
- no privileged key is in the client
- crash/error path is tested
- store listing is truthful
- owner approves publication
