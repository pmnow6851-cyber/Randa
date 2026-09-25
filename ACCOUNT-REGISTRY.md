# RANDA.MKCOOL Account Registry

This file stores NON-SECRET governance metadata only.

**Never place passwords, recovery codes, API keys, private keys, bank details, payout credentials, secret tokens, or personal addresses in this file.**

| Service | Purpose | Status | Canonical Role | MFA | Recovery | Billing | Production Dependency | Last Review | Retirement Plan |
|---|---|---|---|---|---|---|---|---|---|
| GitHub | Canonical source and CI | CANONICAL | Repository / release checks | VERIFY | VERIFY | FREE / VERIFY | YES | PENDING | KEEP |
| Firebase | Backend/support services if required | SUPPORTING / VERIFY | Backend | VERIFY | VERIFY | FREE-TIER TARGET | VERIFY | PENDING | REVIEW |
| Supabase | Optional backend/storage if required | SUPPORTING / VERIFY | Backend | VERIFY | VERIFY | FREE-TIER TARGET | VERIFY | PENDING | REVIEW |
| Google Play | Android distribution | SUPPORTING | App store | VERIFY | VERIFY | EXTERNAL FEE HISTORY / VERIFY | YES WHEN RELEASED | PENDING | KEEP |
| Stripe | Payment processing if active | SUPPORTING | Payment processor | VERIFY | VERIFY | TRANSACTION FEES | YES IF ACTIVE | PENDING | KEEP |
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
