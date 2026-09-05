# RANDA.MKCOOL AIM SYNC SYSTEM — PROJECT STATUS

## Canonical production app

**RANDA.MKCOOL sensitivity calculator** in Base44 is the single canonical application build.

Canonical Base44 app ID:
`69b1df3fb4cc4001bac5c543`

Target public domain:
`randa-aim-sync.com`

Current launch state: **PAYMENT_CONFIGURATION_REQUIRED**.

Do not create or promote a second production app while this canonical build remains active.

## GitHub role

This repository is the project vault, backup and static PWA fallback. It is not a second source of truth.

The `CNAME` reserves:
`randa-aim-sync.com`

The static PWA files are an older v4.3.1 RC fallback and must not silently overwrite the canonical Base44 build.

## Supabase role

Use the single existing project named **RANDA.MKCOOL Aim Sync** as the only Supabase backend.

Current verified state:
- project status: active and healthy
- security advisor: no warnings
- RLS enabled on user-facing tables
- Stripe checkout and webhook Edge Functions exist
- Stripe webhook signature verification is enabled in code
- payment verification currently expects the existing live £4.99 Stripe price

Do not create a second Supabase backend unless this project is intentionally retired.

## Stripe role

Use one Stripe account and one one-time Aim Sync purchase path.

Current verified state:
- live card charges are enabled
- payouts are enabled to the configured UK bank account
- application offer target is £9.99 one-time
- the only currently verified active live Stripe price for the product is £4.99
- checkout must remain disabled until the live Stripe £9.99 price and webhook verification amount/price ID match exactly

Never grant premium access from a client-side flag, redirect alone, or unverified payment reference. Entitlements must come from the verified Stripe webhook/backend path.

## Legacy / archive-only builds

Do not publish or monetise these as separate products:
- Replit RANDA.MKCOOL AIM SYNC SYSTEM build
- Replit Aim Sync Lab
- Replit Aim Recalibrator
- Base44 `Randa`
- older AimCurve copies

Preserve them only as recoverable references until unique data has been verified.

## Consolidation rules

1. One canonical app build.
2. One official public domain.
3. One GitHub repository as code vault / fallback.
4. One Supabase backend.
5. One Stripe purchase path.
6. No private addresses, bank details, private API keys, service-role keys, passwords, signing keys or account identity records in public/client configuration.
7. No checkout activation until price, webhook and entitlement verification agree.
8. Free-tier first. Do not upgrade a builder merely to inspect legacy copies.
9. Automated audits may report and block unsafe releases, but must never silently change sensitivity logic, pricing, payout destinations or security policy.

## Current blockers before public production launch

- `randa-aim-sync.com` DNS is not currently resolving.
- £9.99 live Stripe price is not yet present/verified; current live product price is £4.99.
- Base44 checkout is intentionally disabled until that mismatch is fixed.
- GitHub fallback remains RC-labelled and should not be mistaken for the current canonical build.
