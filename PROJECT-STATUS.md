# RANDA.MKCOOL AIM SYNC SYSTEM — PROJECT STATUS

## Canonical production app

**RANDA.MKCOOL Aim Sync v5 Paid** is the single canonical customer-facing application.

Canonical public deployment:
`https://pmnow6851-cyber.github.io/Randa/`

Canonical source repository:
`pmnow6851-cyber/Randa`

Current launch state: **LIVE_PAID_ONLY**.

The calculator, engine and generated sensitivity values are not available to unpaid users.

## Front-end role

GitHub Pages is the canonical public front end and source-of-truth for the customer-facing PWA.

The previous custom-domain binding was removed because `randa-aim-sync.com` was not resolving. The custom domain must not be re-enabled until DNS is verified working end-to-end.

The v5 service worker purges old caches so the previous release-candidate/free calculator cannot remain available from stale local cache.

## Private calculation engine

Sensitivity calculation logic runs in the Supabase Edge Function:
`calculate-aim-sync`

The calculation method is intentionally absent from the public GitHub front-end source. The Edge Function validates the signed-in user and requires an active paid `pro` entitlement before returning any generated sensitivity matrix.

Do not move the calculation coefficients or method back into public browser JavaScript.

## Supabase production role

Use the single existing project named **RANDA.MKCOOL Aim Sync** as the only production backend.

Current production state:
- project status: active and healthy
- security advisor: no current warnings
- RLS enabled on user-facing tables
- `create-checkout-session` active
- `verify-checkout-return` active and hardened against wrong payment-link, account-email, refund and payment-reference states
- `calculate-aim-sync` active
- `system-health` active and checking database, Stripe secret readiness and webhook signing-secret readiness
- `stripe-webhook` active as a complementary signed event handler for successful payments, full refunds and disputes
- checkout and calculation functions explicitly validate the user inside the function
- production browser/return origins are restricted to the canonical GitHub Pages host; local development remains allowed
- `randa-aim-sync.com` and `www.randa-aim-sync.com` have been removed from the production allowlist until DNS and ownership are verified end-to-end
- Base44 origins are not permitted to create production checkout sessions or call the paid calculation engine
- legacy `purchase_claims` is locked from `anon` and `authenticated` table access; production entitlement is granted only through server-verified Stripe state

## Stripe payment path

Use the single live **RandaMkCool.Systems** Stripe account and the official Aim Sync checkout path.

Approved customer price:
- **£9.99 GBP one-time**

Official production flow:
1. A signed-in customer starts checkout from the canonical GitHub Pages app.
2. Supabase `create-checkout-session` validates the signed-in user and approved origin, then returns the canonical £9.99 Stripe Payment Link with the user ID as `client_reference_id` and the signed-in email prefilled.
3. Stripe creates the Checkout Session when the customer completes checkout and redirects first to Supabase `verify-checkout-return`, embedding the Stripe Checkout Session ID.
4. `verify-checkout-return` retrieves that Checkout Session directly from Stripe and requires the canonical active Payment Link, paid status, one-time payment mode, £9.99 GBP amount, approved product metadata, valid user reference, matching account/payment email, a valid PaymentIntent and no full refund.
5. Only a verified payment for `randa_mkcool_aim_sync_pro` grants the `pro` entitlement, stored against the verified Stripe PaymentIntent reference.
6. After entitlement is written, the verifier redirects the customer to the canonical app with a success return. The signed `stripe-webhook` remains an independent event path and revokes paid access on a full refund or dispute.
7. `calculate-aim-sync` requires an active Stripe-backed `pro` entitlement before returning any paid output. It does not expose or duplicate Stripe secrets in the browser.

This server-verified return path is the primary unlock mechanism and does not rely on a client-side success flag.

The signed `stripe-webhook` complements the return verifier. It independently validates live Stripe events and protects entitlement state when later refund or dispute events occur.

### Canonical Payment Link status — 10 September 2026

- The active production Payment Link is the £9.99 GBP one-time offer.
- Its metadata includes `product=randa_mkcool_aim_sync_pro`, aligned with `verify-checkout-return` validation.
- Its after-payment redirect routes through `verify-checkout-return` before the customer returns to the canonical app.
- The old £4.99 Payment Link is inactive and its old price is inactive.
- Do not reactivate legacy payment links or introduce a second customer payment route.

## Base44 role

Base44 app ID `69b1df3fb4cc4001bac5c543` is retained only as a secondary locked builder/reference.

It is not the canonical checkout or calculation engine and is not permitted as a production origin for checkout or calculation calls. Current Base44 third-party connector count is zero.

## Legacy / archive-only builds

Do not publish or monetise these as separate products:
- Replit RANDA.MKCOOL AIM SYNC SYSTEM build
- Replit Aim Sync Lab
- Replit Aim Recalibrator
- Base44 `Randa`
- older AimCurve copies

Preserve them only as recoverable references until unique data has been verified. The audited Replit AIM build does not contain active Stripe, Supabase or OpenAI integrations for the AIM app.

## OpenAI API role

OpenAI API is not required by the production Aim Sync architecture. Do not add API credits or expose OpenAI API keys in the app, GitHub, Base44, Replit or client-side code. Any unused OpenAI API key created during experiments should be revoked in the OpenAI Platform account.

## Production control rules

1. One canonical public app.
2. No free calculator access or free sensitivity outputs.
3. One GitHub repository as front-end source-of-truth and backup vault.
4. One private Supabase calculation/payment backend.
5. One approved customer price: £9.99 GBP one-time.
6. No calculation method in public front-end code.
7. No private addresses, bank details, private API keys, service-role keys, passwords, signing keys or account identity records in public/client configuration.
8. Entitlements come only from server-verified Stripe payment state.
9. Full refunds and disputes revoke paid access.
10. Base44 and legacy builds cannot create production checkout sessions or retrieve paid calculations.
11. Automated audits may report and block unsafe releases, but must never silently alter pricing, payout destination, entitlement policy or calculation logic.
12. Dormant or unverified domains must not be permitted as production checkout, calculation or payment-return origins.
13. Genuine gameplay proof and public promotional assets must be separated from raw screenshots that contain personal profile information.
14. Generated promotional artwork must never be presented as genuine gameplay proof.

## Revocation / hardening status — 10 September 2026

Completed:
- removed the unverified custom domain from production checkout origin allowlist
- removed the unverified custom domain from the paid calculation origin allowlist
- removed the unverified custom domain from the payment return allowlist
- confirmed Supabase security advisor reports no current warnings
- locked the unused legacy `purchase_claims` table from anonymous and authenticated client access
- confirmed Base44 has no connected third-party connectors
- confirmed the archive-only Replit AIM app has no active production Stripe, Supabase or OpenAI integration
- activated a repository ruleset on the default branch that blocks deletion and force-pushes, requires pull requests, and requires linear history
- deactivated the old £4.99 Stripe Payment Link
- aligned the active £9.99 Payment Link product metadata with server-side checkout-return verification
- routed the live £9.99 Stripe completion redirect through the server-side payment verifier before returning customers to the app
- fixed payment-return entitlement writes to use the validated Stripe PaymentIntent reference rather than the Checkout Session reference
- added canonical Payment Link, account-email and full-refund validation to the return verifier
- expanded the public health signal to require database, Stripe secret and webhook signing-secret readiness without exposing those secrets
- separated raw private social screenshots, genuine winning proof, social-ready material, generated reference artwork, research and legacy material into distinct protected folders

Remaining owner-side actions:
- review Google third-party access and remove any no-longer-needed experimental services
- revoke any unused experimental OpenAI API key directly in the OpenAI Platform account
- keep `randa-aim-sync.com` disabled until registrar/DNS records are fixed and verified

## Growth controls

- Use genuine winning gameplay and victory screens as proof.
- Keep the calculation engine private and sell the outcome rather than the method.
- Use one official app URL and the one active £9.99 checkout route.
- Keep promotion organic unless the owner explicitly changes the no-spend rule.
- Do not claim guaranteed wins, kills or performance.
- Do not say “early access” while the product is live.
- Keep generated art as promotional/reference material only, never as gameplay evidence.
