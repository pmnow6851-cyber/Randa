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

## Supabase role

Use the single existing project named **RANDA.MKCOOL Aim Sync** as the only production backend.

Verified production state:
- project status: active and healthy
- security advisor: no warnings
- RLS enabled on user-facing tables
- Stripe checkout Edge Function active
- Stripe webhook Edge Function active
- paid calculation Edge Function active
- system health Edge Function active
- checkout and calculation functions explicitly validate the user JWT inside the function
- browser CORS preflight is supported before authenticated processing

Do not create a second Supabase backend unless this project is intentionally retired.

## Stripe role

Use the single live RandaMkCool.Systems Stripe account and one one-time Aim Sync purchase path.

Production payment path:
- price shown to customer: **£9.99 GBP one-time**
- Checkout creates the £9.99 amount server-side
- customer identity is tied to the signed-in Supabase user ID
- webhook verifies paid status, mode, amount, currency and product metadata
- successful verified payment grants active `pro` entitlement
- full refund revokes the entitlement
- the old £4.99 Stripe price object is not used by the live checkout path

Never grant premium access from a client-side flag, redirect alone, or unverified payment reference.

## Base44 role

Base44 app ID `69b1df3fb4cc4001bac5c543` is retained only as a secondary locked builder/reference.

It is not the canonical customer checkout or calculation engine. Its configuration is marked `free_access=false`, and it must not provide a free calculator or become a second production payment path.

## Legacy / archive-only builds

Do not publish or monetise these as separate products:
- Replit RANDA.MKCOOL AIM SYNC SYSTEM build
- Replit Aim Sync Lab
- Replit Aim Recalibrator
- Base44 `Randa`
- older AimCurve copies

Preserve them only as recoverable references until unique data has been verified.

## Production control rules

1. One canonical public app.
2. No free calculator access or free sensitivity outputs.
3. One GitHub repository as front-end source-of-truth and backup vault.
4. One private Supabase calculation/payment backend.
5. One Stripe purchase path at £9.99 GBP one-time.
6. No calculation method in public front-end code.
7. No private addresses, bank details, private API keys, service-role keys, passwords, signing keys or account identity records in public/client configuration.
8. Entitlements come only from verified server-side payment state.
9. Refunds revoke paid access.
10. Automated audits may report and block unsafe releases, but must never silently alter pricing, payout destination, entitlement policy or calculation logic.

## Autonomous audit

The daily **RANDA Live Self-Audit** checks the deployment, public route, Supabase security, system health, Stripe £9.99 path, entitlement architecture, Base44 bypass risk, stale caching, public formula leakage and deployment drift.

## Remaining external item

`randa-aim-sync.com` remains disabled until its registrar/DNS records are fixed and verified. Until then, the GitHub Pages URL above is the canonical public route.
