# RANDA.MKCOOL AIM SYNC SYSTEM v5 PAID

Canonical customer-facing Progressive Web App for RANDA.MKCOOL Aim Sync.

## Production

- Status: **LIVE_PAID_ONLY**
- Canonical source: `pmnow6851-cyber/Randa`
- Canonical public route: `https://pmnow6851-cyber.github.io/Randa/`
- Approved price: **£9.99 GBP one-time**
- Hosting: GitHub Pages from `main` / repository root

The custom domain `randa-aim-sync.com` is intentionally disabled until its DNS is verified end-to-end. Do not add a `CNAME` file before that verification is complete.

## Architecture

This public repository contains only the customer-facing PWA shell.

The sensitivity calculation method and payment entitlement logic remain server-side in the production RANDA.MKCOOL Supabase backend.

Production payment/unlock path:

`GitHub Pages app → Supabase create-checkout-session → Stripe Checkout (£9.99) → Supabase verify-checkout-return → paid entitlement → calculate-aim-sync`

The successful Checkout Session is retrieved from Stripe server-side and checked for:
- paid status
- one-time payment mode
- exact £9.99 GBP total
- approved product metadata
- matching signed-in user identity

The paid calculation function also periodically re-verifies the Stripe payment and associated charge. A fully refunded payment causes paid access to be revoked.

Never move private calculation coefficients, Stripe secrets, Supabase service-role credentials, signing keys, passwords, bank details, private addresses, or other private account information into this repository.

## Paid-access rules

1. Signing up or signing in does not unlock Aim Sync.
2. Premium entitlement must come from verified server-side Stripe payment state.
3. The customer price shown by the canonical app is £9.99 GBP one-time.
4. The calculation endpoint rejects users without active paid entitlement.
5. A fully refunded payment revokes paid access when Stripe state is re-verified.
6. No client-side flag, redirect parameter, localStorage value, copied payment reference, Base44 build, or legacy payment link may grant premium access.

## Supabase Edge Functions

Production functions include:
- `create-checkout-session`
- `verify-checkout-return`
- `calculate-aim-sync`
- `system-health`
- `stripe-webhook` (retained as a secondary event handler)

Checkout and calculation CORS is restricted to the canonical GitHub Pages host, the future approved custom domain, and local development. Base44 origins are intentionally excluded from the production payment and calculation path.

## Legacy payment link

A historical £4.99 Stripe Payment Link still exists in the Stripe account but is **not** part of this production architecture. It is not referenced by the canonical app and cannot create a valid Aim Sync entitlement. Deactivate it when Stripe write access is available.

## Project structure

```text
/
├── .github/workflows/production-audit.yml
├── .gitignore
├── .nojekyll
├── PROJECT-STATUS.md
├── README.md
├── index.html
├── manifest.webmanifest
├── service-worker.js
└── icons/
    ├── icon-192.png
    ├── icon-512.png
    └── maskable-512.png
```

## Deployment

GitHub Pages deploys the `main` branch from `/ (root)`.

For app releases that change the public shell, update the v5 paid cache namespace in `service-worker.js` so stale clients cannot remain pinned to an older front end.

## Production audit

`.github/workflows/production-audit.yml` runs on pushes to `main`, once daily, and on manual dispatch. It checks the canonical production files, GitHub Pages state, paid-only markers, PWA configuration and tracked-source secret patterns.

## Monetisation note

This repository is a web/PWA application. Native Google AdMob SDK components cannot run directly inside GitHub Pages HTML. If a future native Android/Flutter edition is released, keep it as a controlled client of the same private entitlement/calculation backend rather than creating a second public calculation engine.

## Ownership and change control

Treat this repository as the single front-end source of truth. Do not publish legacy Replit/Base44 experiments as parallel production apps, and do not silently change pricing, payout routing, entitlement policy, or calculation logic through automated jobs.

See `PROJECT-STATUS.md` for the current production control record.
