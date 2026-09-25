# RANDA.MKCOOL AIM SYNC SYSTEM — PROJECT STATUS

Last reconciled: **23 September 2026**

## Canonical production app

**RANDA.MKCOOL Aim Sync v5 Paid** is the single canonical customer-facing application.

Canonical public deployment:
`https://pmnow6851-cyber.github.io/Randa/`

Canonical source repository:
`pmnow6851-cyber/Randa`

Current launch state: **LIVE_PAID_ONLY**.

The calculator, engine and generated sensitivity values are not available to unpaid users.

## Front-end role

GitHub Pages is the canonical public front end and source of truth for the customer-facing PWA.

The previous custom-domain binding remains disabled because `randa-aim-sync.com` was not verified working end-to-end. Do not re-enable that domain until DNS and ownership are deliberately verified.

The v5 service worker purges old caches so an older free/release-candidate calculator cannot remain available from stale local cache.

## Private calculation engine

Sensitivity calculation logic runs in the Supabase Edge Function:
`calculate-aim-sync`

The calculation method is intentionally absent from the public GitHub front-end source. The Edge Function validates the signed-in user and requires an active Stripe-backed `pro` entitlement before returning a generated sensitivity matrix.

The calculation endpoint also enforces bounded request size and per-user abuse throttling. These protections must not be used to move the calculation method back into public browser or Android code.

## Supabase production role

Use the single existing project named **RANDA.MKCOOL Aim Sync** as the only production backend.

Current production controls:
- project status: active and healthy
- Supabase security advisor: no current findings after the 13 September 2026 review
- RLS enabled on all public application tables
- user-owned profile/config rows are scoped to the authenticated user
- `purchase_claims` remains service-side only; anonymous/authenticated roles are explicitly denied by policy and do not have table privileges
- privileged payment helper functions are executable only by trusted server roles
- `create-checkout-session` is active and validates the signed-in user before returning the canonical payment route
- `verify-checkout-return` is active as a safe **UX redirect only** and cannot grant entitlement
- `calculate-aim-sync` is active, paid/pro-gated and private
- `generate-gunsmith` is active and paid/pro-gated; customer-facing integration is a separate controlled feature task
- `system-health` is active and checks database plus live webhook-signing readiness without exposing secrets
- `stripe-webhook` is active and is the **single entitlement authority** for successful payments, full refunds and disputes
- production browser origins are restricted to the canonical GitHub Pages host; local development remains allowed
- Base44 and legacy origins are not permitted to retrieve paid calculations or become a second production checkout path

## Stripe payment path

Use the single live **RandaMkCool.Systems** Stripe account and the official Aim Sync checkout path.

Approved customer price:
- **£9.99 GBP one-time**

Official production flow:
1. A signed-in customer starts checkout from the canonical GitHub Pages app.
2. Supabase `create-checkout-session` validates the user and approved client/origin, then returns the canonical £9.99 Stripe Payment Link with the signed-in account reference attached.
3. Stripe creates the Checkout Session and processes the payment.
4. The signed `stripe-webhook` independently receives the live Stripe event and validates the canonical Payment Link, paid one-time state, £9.99 GBP amount/currency, valid user reference, PaymentIntent and matching account/payment identity before calling the service-only entitlement function.
5. Only that signed webhook path may grant the `pro` entitlement. Entitlement is stored against the verified Stripe PaymentIntent reference.
6. The Payment Link completion redirect may pass through `verify-checkout-return`, but that endpoint is deliberately non-authoritative: it validates only a safe return destination/session-id shape and redirects the browser back to the canonical app. It does **not** create or change paid access.
7. On return, the app re-checks the server-side entitlement. Access appears only after the signed webhook has verified the payment.
8. A full refund or Stripe dispute is handled by the same signed webhook and revokes paid access.
9. `calculate-aim-sync` and `generate-gunsmith` require an active Stripe-backed `pro` entitlement before returning protected outputs.

The signed Stripe webhook is the single source of truth for payment-to-entitlement state. Never restore client-side success flags or browser-return logic as an entitlement authority.

### Canonical Payment Link status

- The production Aim Sync Payment Link is the **£9.99 GBP one-time** offer.
- Its metadata identifies the canonical Aim Sync product.
- Its completion route returns through the safe UX redirect before the customer returns to the canonical app.
- The obsolete £4.99 Payment Link and old price are inactive.
- Do not reactivate legacy Aim Sync payment links or introduce a second Aim Sync customer payment route.

## Gunsmith expansion

The backend `generate-gunsmith` Edge Function is active and protected by the same authenticated, Stripe-backed `pro` entitlement boundary used by Aim Sync.

Current boundary:
- backend generation is available only to paid/pro users
- generated build codes are RANDA.MKCOOL references, not native CODM import codes
- the function has per-user throttling and bounded request size
- customer-facing web/Android Gunsmith UI is **not yet part of the canonical production front end**

Integrate the UI only through a reviewed production change. Do not weaken the Aim Sync paid gate or expose protected calculation logic while doing so.

## Android / Google Play role

The Flutter Android client is in the canonical repository and is **not yet approved for public Google Play release**.

As of 23 September 2026:
- the Android project is committed under `flutter_app/android/` rather than generated only inside CI
- application ID/namespace is locked to `systems.randamkcool.randa_mkcool_aim_sync`
- minSdk remains 24 and compile/target SDK remains 36
- Android backup and cleartext traffic are disabled
- INTERNET permission is present for the authenticated network client
- CI builds a debug APK and a release AAB validation artifact from committed source and rejects accidental debug signing for release
- the Android, RANDA Production Audit and CodeQL checks passed on the source change before merge
- signing keys, Firebase client configuration, bank/payment secrets and payout data remain outside public source
- Firebase is not required by the current production client and no `google-services.json` dependency is required
- the dormant AdMob/banner path is removed; there is no free or ad-supported monetisation branch

Keep the GitHub Pages paid PWA canonical until the Android release checklist is complete. Owner-gated release items include:
- owner-controlled release/upload signing kept outside public GitHub
- physical-device account, entitlement-restoration, calculator, copy and recovery testing
- a Google Play-compliant billing/distribution decision
- privacy policy, account-deletion path, consent and Play disclosures
- final signed API-36+ Android App Bundle and deliberate owner approval

## Base44 role

Base44 is retained only as a secondary locked builder/reference.

It is not the canonical checkout or calculation engine and must not be permitted as a production origin for checkout or protected calculations.

## Legacy / archive-only builds

Do not publish or monetise these as separate Aim Sync products:
- Replit RANDA.MKCOOL AIM SYNC SYSTEM build
- Replit Aim Sync Lab
- Replit Aim Recalibrator
- Base44 `Randa`
- older AimCurve copies
- other abandoned/test deployments that are not the canonical GitHub Pages app

Preserve legacy material only as recoverable reference until unique data has been checked. Do not reconnect archived systems to production payment or protected calculation state.

## OpenAI API role

OpenAI API is not required by the production Aim Sync architecture. Do not add paid API credits or expose OpenAI API keys in the app, GitHub, Base44, Replit or client-side code. Any unused experimental API credential should be revoked directly in its provider account.

## Production control rules

1. One canonical public Aim Sync app.
2. No free calculator access or free sensitivity outputs.
3. One GitHub repository as front-end source of truth and backup vault.
4. One private Supabase calculation/payment backend.
5. One approved Aim Sync customer price: £9.99 GBP one-time.
6. No calculation method in public front-end or Android client code.
7. No private addresses, bank details, API secrets, service-role keys, passwords, signing keys or recovery material in public/client configuration.
8. Entitlements come only from the signed server-side Stripe webhook.
9. Browser checkout-return state never grants access.
10. Full refunds and disputes revoke paid access through the signed webhook.
11. Base44 and legacy builds cannot create a second production path or retrieve protected calculations.
12. Automated audits may report and block unsafe releases, but must never silently alter pricing, payout destination, entitlement policy or calculation logic.
13. Dormant or unverified domains must not be permitted as production checkout, calculation or return origins.
14. Genuine gameplay proof and public promotional assets must stay separate from private/raw screenshots.
15. Generated promotional artwork must never be represented as genuine gameplay proof.
16. New protected features such as Gunsmith must inherit authentication, paid-entitlement and privacy controls rather than creating bypasses.

## Hardening status — 23 September 2026

Completed:
- canonical GitHub Pages app retained as the single production front end
- unverified custom domain kept out of checkout, calculation and return allowlists
- Supabase security advisor reviewed with no current findings
- all public application tables confirmed with RLS enabled
- legacy `purchase_claims` client policies replaced with explicit deny-all anonymous/authenticated policy while retaining service-side payment processing
- service-only payment helper permissions verified
- active £9.99 Aim Sync Payment Link aligned with the signed webhook path
- obsolete £4.99 Payment Link kept inactive
- signed live Stripe webhook confirmed enabled for successful checkout, asynchronous success, full refund and dispute events
- payment entitlement authority consolidated in the signed webhook
- checkout-return endpoint confirmed UX-only and unable to grant access
- private calculation endpoint hardened with bounded requests and per-user abuse throttling
- protected Gunsmith backend confirmed authenticated and pro-gated
- repository ruleset remains active on `main`: pull requests required, deletion and force-push blocked, linear history required
- web auth tokens use session-scoped storage and the public client carries a no-referrer policy
- repository audit rejects tracked secrets, signing/credential files, PII-like literals and protected calculation markers in public client code
- third-party GitHub Actions are pinned to immutable revisions and CodeQL is aligned on the reviewed v4.38.1 action release
- the Android project is committed under `flutter_app/android/` and its build/release-validation path passed Android, production-audit and CodeQL checks before merge on 23 September 2026
- the Android paid-only client contains no Firebase requirement and no AdMob/free-access monetisation path
- scheduled production and OS audits continue to guard canonical source/deployment drift

Remaining owner-side/provider actions:
- verify the official app on a physical Samsung Galaxy A56, including sign-in, paid-access restoration, calculation and One-Tap Copy
- create/protect Android signing material outside GitHub before any Play production build
- complete Google Play billing/distribution, privacy, deletion, consent and listing gates
- review the recently authorised Supabase GitHub OAuth connection and remove it only if it is not intentionally used for developer tooling
- verify the RANDA business email directly in GitHub account settings if still pending
- review Google third-party access and revoke no-longer-needed experimental services
- keep `randa-aim-sync.com` disabled until registrar/DNS records are fixed and verified

## Growth controls

- Use genuine winning gameplay and victory screens as proof.
- Keep the calculation engine private and sell the outcome rather than the method.
- Use the official app URL and one active £9.99 Aim Sync checkout route.
- Keep promotion organic unless the owner explicitly changes the no-spend rule.
- Do not claim guaranteed wins, kills or performance.
- Do not say “early access” while the product is live.
- Keep generated art as promotional/reference material only, never as gameplay evidence.
