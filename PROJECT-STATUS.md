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
- security advisor: no warnings
- RLS enabled on user-facing tables
- `create-checkout-session` active
- `verify-checkout-return` active
- `calculate-aim-sync` active
- `system-health` active
- `stripe-webhook` retained as a secondary event handler
- checkout and calculation functions explicitly validate the user inside the function
- browser CORS is restricted to the canonical GitHub Pages host, the future approved custom domain, and local development
- Base44 origins are not permitted to create production checkout sessions or call the paid calculation engine

## Stripe payment path

Use the single live **RandaMkCool.Systems** Stripe account and the official Aim Sync checkout path.

Approved customer price:
- **£9.99 GBP one-time**

Official production flow:
1. Signed-in customer starts checkout from the canonical GitHub Pages app.
2. Supabase creates the £9.99 Stripe Checkout Session server-side.
3. Stripe returns the successful session to `verify-checkout-return`.
4. Supabase retrieves the Checkout Session directly from Stripe and verifies paid status, mode, amount, currency, product metadata and customer user ID.
5. Only a valid £9.99 GBP payment grants the `pro` entitlement.
6. The paid calculation function periodically re-verifies the Stripe Checkout Session and associated charge. A fully refunded payment is rejected and paid access is revoked.

This server-verified return path is the primary unlock mechanism and does not rely on a client-side success flag.

The existing `stripe-webhook` function remains available for future direct Stripe webhook delivery, but a live Stripe webhook endpoint is not currently required for the primary unlock path.

## Legacy Stripe Payment Link

A separate legacy **£4.99** Stripe Payment Link still exists in the Stripe account and is not part of production Aim Sync.

It is not referenced by the canonical app, has no valid production entitlement metadata, and cannot unlock the paid calculator. It should be deactivated in Stripe as soon as write access is available so there is only one customer payment route.

## Base44 role

Base44 app ID `69b1df3fb4cc4001bac5c543` is retained only as a secondary locked builder/reference.

It is not the canonical checkout or calculation engine and is not permitted as a production origin for checkout or calculation calls.

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
5. One approved customer price: £9.99 GBP one-time.
6. No calculation method in public front-end code.
7. No private addresses, bank details, private API keys, service-role keys, passwords, signing keys or account identity records in public/client configuration.
8. Entitlements come only from server-verified Stripe payment state.
9. Full refunds revoke paid access.
10. Base44 and legacy builds cannot create production checkout sessions or retrieve paid calculations.
11. Automated audits may report and block unsafe releases, but must never silently alter pricing, payout destination, entitlement policy or calculation logic.

## Remaining external items

- Deactivate the legacy £4.99 Stripe Payment Link.
- Keep `randa-aim-sync.com` disabled until registrar/DNS records are fixed and verified.
