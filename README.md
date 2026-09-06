# RANDA.MKCOOL AIM SYNC SYSTEM v5 PAID

Canonical customer-facing Progressive Web App for RANDA.MKCOOL Aim Sync.

## Project definition

**RANDA.MKCOOL Aim Sync is a paid COD Mobile sensitivity-calibration system for players struggling with inconsistent aim, delivering server-generated MP/BR sensitivity profiles through a one-time £9.99 unlock.**

## Production

- Status: **LIVE_PAID_ONLY**
- Canonical source: `pmnow6851-cyber/Randa`
- Canonical public route: `https://pmnow6851-cyber.github.io/Randa/`
- Approved price: **£9.99 GBP one-time**
- Hosting: GitHub Pages from `main` / repository root

The custom domain `randa-aim-sync.com` is intentionally disabled until its DNS is verified end-to-end. Do not add a `CNAME` file before that verification is complete.

## Architecture

This public repository contains only the customer-facing PWA shell plus non-sensitive operations/audit/growth automation.

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

Checkout and calculation requests are currently permitted only from the canonical GitHub Pages host and local development. `randa-aim-sync.com`, `www.randa-aim-sync.com`, Base44 origins, and other unverified origins are excluded until ownership and DNS are verified end-to-end.

## Legacy payment link

A historical £4.99 Stripe Payment Link still exists in the Stripe account but is **not** part of this production architecture. It is not referenced by the canonical app and cannot create a valid Aim Sync entitlement. Deactivate it when Stripe write access is available.

## RANDA.MKCOOL OS automation

The repository now has a non-sensitive operations layer around the live paid app.

### Daily self-audit

`.github/workflows/randamkcool-os-audit.yml` runs every day at **02:00 UTC** and on manual dispatch. It calls `scripts/randa_audit.py` to check:
- canonical production state
- required files
- paid-only and £9.99 markers
- high-risk secret patterns
- accidental PII-like literals in tracked source
- client-side refund/payout/transfer creation primitives
- canonical endpoint uptime and paid markers

It refreshes `DAILY_AUDIT_REPORT.md` and opens a GitHub incident if a check fails.

This job deliberately has no bank credentials, Stripe secret key, Supabase service-role key, or customer transaction access.

### Dependency maintenance

`.github/dependabot.yml` performs weekly GitHub Actions dependency checks and proposes updates as pull requests.

### Zero-cost growth

`.github/workflows/weekly-growth.yml` runs weekly and generates a small deterministic product/SEO update using `scripts/generate_weekly_update.py`. It uses no paid AI or external API and cannot reveal paid sensitivity outputs or calculation logic.

SEO discovery files:
- `robots.txt`
- `sitemap.xml`
- `updates/index.html`

External auto-posting is intentionally not enabled by default because platform API pricing, rate limits and anti-spam rules can change. See `docs/GROWTH-RUNBOOK.md`.

## Project structure

```text
/
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       ├── production-audit.yml
│       ├── randamkcool-os-audit.yml
│       └── weekly-growth.yml
├── docs/
│   ├── GROWTH-RUNBOOK.md
│   ├── OPERATIONS.md
│   ├── RECOVERY-RUNBOOK.md
│   └── SECURITY-PRIVACY.md
├── scripts/
│   ├── generate_weekly_update.py
│   └── randa_audit.py
├── updates/
│   └── index.html
├── .gitignore
├── .nojekyll
├── AI-HANDOFF.md
├── DAILY_AUDIT_REPORT.md
├── PROJECT-STATUS.md
├── README.md
├── index.html
├── manifest.webmanifest
├── robots.txt
├── service-worker.js
├── sitemap.xml
└── icons/
    ├── icon-192.png
    ├── icon-512.png
    └── maskable-512.png
```

## Deployment

GitHub Pages deploys the `main` branch from `/ (root)`.

For app releases that change the public shell, update the v5 paid cache namespace in `service-worker.js` so stale clients cannot remain pinned to an older front end.

## Production audit

`.github/workflows/production-audit.yml` remains the original production guardrail and runs on pushes to `main`, once daily, and on manual dispatch. It checks the canonical production files, GitHub Pages state, paid-only markers, PWA configuration and tracked-source secret patterns.

The RANDA.MKCOOL OS daily audit supplements this existing workflow rather than replacing it.

## Monetisation note

This repository is a web/PWA application. Native Google AdMob SDK components cannot run directly inside GitHub Pages HTML. If a future native Android/Flutter edition is released, keep it as a controlled client of the same private entitlement/calculation backend rather than creating a second public calculation engine.

No application code or GitHub automation may initiate owner payouts, transfers, purchases or bank withdrawals. Payment-provider fees, disputes, chargebacks or legally required refunds remain provider/owner processes and cannot truthfully be guaranteed away by application code.

## Ownership and change control

Treat this repository as the single front-end source of truth. Do not publish legacy Replit/Base44 experiments as parallel production apps, and do not silently change pricing, payout routing, entitlement policy, authentication policy or calculation logic through automated jobs.

Operations/runbooks:
- `docs/OPERATIONS.md`
- `docs/SECURITY-PRIVACY.md`
- `docs/RECOVERY-RUNBOOK.md`
- `docs/GROWTH-RUNBOOK.md`

See `PROJECT-STATUS.md` for the current production control record.
