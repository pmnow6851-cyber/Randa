# RANDA.MKCOOL Account Registry

This file stores NON-SECRET governance metadata only.

**Never place passwords, recovery codes, API keys, private keys, bank details, payout credentials, secret tokens, or personal addresses in this file.**

| Service | Purpose | Status | Canonical Role | MFA | Recovery | Billing | Production Dependency | Last Review | Retirement Plan |
|---|---|---|---|---|---|---|---|---|---|
| GitHub | Canonical source, Pages and CI | CANONICAL | Repository / public PWA | VERIFY | VERIFY | VERIFY | YES | 2026-09-26 (project role only) | KEEP |
| Firebase | Optional future support service | TEST | None in the paid Aim Sync production path | VERIFY | VERIFY | VERIFY | NO | PENDING | REVIEW |
| Supabase | Auth, entitlements, private calculation and Edge Functions | CANONICAL | Production backend | VERIFY | VERIFY | VERIFY | YES | 2026-09-26 (project role and security advisor) | KEEP |
| Google Play | Future Android distribution | SUPPORTING | App store; public release blocked | VERIFY | VERIFY | REGISTRATION / VERIFY | NO CURRENT / YES WHEN RELEASED | PENDING | KEEP |
| Stripe | Live £9.99 one-time payment processing | CANONICAL | Payment processor and signed webhook source | VERIFY | VERIFY | TRANSACTION FEES | YES | 2026-09-26 (project role only) | KEEP |
| Social platforms | Organic promotion | SUPPORTING | Marketing | VERIFY | VERIFY | £0 PAID ADS | NO | PENDING | REVIEW |
| Other builders | Legacy/prototypes | ARCHIVE / RETIRE | None unless justified | VERIFY | VERIFY | £0 TARGET | NO | PENDING | CONSOLIDATE |

## Status values

- CANONICAL
- SUPPORTING
- TEST
- ARCHIVE
- RETIRE

## Review checklist

- Purpose still required?
- MFA enabled where supported?
- Recovery owner-controlled?
- Permissions least-privilege?
- Any unnecessary collaborators?
- Any paid plan or trial?
- Any duplicate platform?
- Any stale token/integration?
- Any public personal data?
- Any secret stored outside approved secret storage?
- Safe retirement plan documented before deletion?

Project-role reviews do not verify account MFA, recovery settings, ownership, subscription billing, Play registration, or a publishable signed Android bundle. Keep those fields at `VERIFY` until checked in the provider account.
