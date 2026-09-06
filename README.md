# RANDA.MKCOOL AIM SYNC SYSTEM v5 PAID

Canonical customer-facing Progressive Web App for RANDA.MKCOOL Aim Sync.

## Production

- Status: **LIVE_PAID_ONLY**
- Canonical source: `pmnow6851-cyber/Randa`
- Canonical public route: `https://pmnow6851-cyber.github.io/Randa/`
- Price: **£9.99 GBP one-time**
- Hosting: GitHub Pages from `main` / repository root

The custom domain `randa-aim-sync.com` is intentionally disabled until its DNS is verified end-to-end. Do not add a `CNAME` file before that verification is complete.

## Architecture

This public repository contains only the customer-facing PWA shell.

The sensitivity calculation method and payment entitlement logic must remain server-side in the existing RANDA.MKCOOL Supabase backend. The browser calls the authenticated Edge Functions for checkout, entitlement-aware calculation, and system health.

Never move private calculation coefficients, Stripe secrets, Supabase service-role credentials, webhook secrets, signing keys, passwords, bank details, private addresses, or other private account information into this repository.

## Paid-access rules

1. Signing up or signing in does not by itself unlock Aim Sync.
2. Premium entitlement must come from verified server-side payment state.
3. The customer price shown by the canonical app is £9.99 GBP one-time.
4. The calculation endpoint must reject users without active paid entitlement.
5. Refund handling remains server-side and should revoke paid entitlement when the verified payment is fully refunded.
6. No client-side flag, redirect parameter, localStorage value, or copied payment reference may grant premium access.

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

`.github/workflows/production-audit.yml` runs on pushes to `main`, once daily, and on manual dispatch. It checks:

- required production files
- canonical GitHub Pages state
- absence of an unexpected custom-domain `CNAME`
- PWA manifest validity and GitHub Pages path scope
- service-worker syntax and paid cache namespace
- high-risk tracked secret patterns
- the approved £9.99 paid-only markers
- the canonical public endpoint

On failure it opens or updates a GitHub incident issue. After recovery it closes that incident automatically.

## Important monetisation note

This repository is a web/PWA application. Native Google AdMob SDK components cannot run directly inside GitHub Pages HTML. If a future native Android/Flutter edition is released, keep it as a controlled client of the same private entitlement/calculation backend rather than creating a second public calculation engine.

## Ownership and change control

Treat this repository as the single front-end source of truth. Do not publish legacy Replit/Base44 experiments as parallel production apps, and do not silently change pricing, payout routing, entitlement policy, or calculation logic through automated jobs.

See `PROJECT-STATUS.md` for the current production control record.
