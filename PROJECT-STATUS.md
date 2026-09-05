# RANDA.MKCOOL AIM SYNC SYSTEM — PROJECT STATUS

## Canonical production app

**RANDA.MKCOOL AIM SYNC SYSTEM** on Replit is the single active application and the only build that should receive product changes.

Public app URL:
https://randamkcool-aim-sync-system--paulmoran6851.replit.app

## GitHub role

This repository is the project vault / backup and GitHub Pages deployment target.

Custom domain reserved in `CNAME`:
`randa-aim-sync.com`

The current static files in this repository are an older v4.3.1 RC backup. Do not treat them as newer than the canonical Replit build unless they are deliberately refreshed from it.

## Supabase role

Use the single existing project named **RANDA.MKCOOL Aim Sync** as the only backend if remote accounts, saved profiles, entitlements, or purchase claims are activated later.

Current status at consolidation:
- security advisor: no warnings
- public app tables exist and have authenticated RLS policies
- `profiles`: 0 rows
- `aim_configs`: 0 rows
- `access_entitlements`: 0 rows
- `purchase_claims`: 0 rows
- the current Replit frontend is local-first and is not connected to Supabase

Do not create a second backend unless the canonical project is intentionally retired.

## Legacy / archive-only apps

Do not publish, monetise, or treat these as source-of-truth builds:
- Replit: `Aim Sync Lab`
- Replit: `Aim Recalibrator`
- Base44: `RANDA.MKCOOL sensitivity calculator`
- Base44: `Randa`

Keep them only as recoverable references until their useful ideas have been reviewed or merged into the canonical app.

## Consolidation rules

1. One active product: RANDA.MKCOOL AIM SYNC SYSTEM.
2. One public production URL at a time.
3. One GitHub repository as the code vault / backup.
4. One Supabase project only.
5. Never put private addresses, bank details, private API keys, service-role keys, passwords, signing keys, or other secrets in client code or this repository.
6. Do not add a payment or unlock link until the exact receiving account and live link have been verified. Once verified, use one official payment path only.
7. Free-tier first. Do not upgrade Base44 or another builder merely to inspect or maintain legacy copies.
8. Generated build output is not source-of-truth and should not be hand-edited.

## Current consolidation work

The canonical Replit app is being hardened to fix standalone production builds, PWA path handling, offline caching, local-storage failure handling, clipboard verification, import validation, profile-lock consistency, desktop layout, and redundant scaffold dependencies while preserving the existing calculator behavior and local user data.
