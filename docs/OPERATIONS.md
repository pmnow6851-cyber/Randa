# RANDA.MKCOOL OS — OPERATIONS MANUAL

## Project definition

**RANDA.MKCOOL Aim Sync is a paid COD Mobile sensitivity-calibration system for players struggling with inconsistent aim, delivering server-generated MP/BR sensitivity profiles through a one-time £9.99 unlock.**

## Source of truth

- Canonical repository: `pmnow6851-cyber/Randa`
- Canonical branch: `main`
- Canonical public app: `https://pmnow6851-cyber.github.io/Randa/`
- Production state: `LIVE_PAID_ONLY`
- Canonical control record: `PROJECT-STATUS.md`
- Private calculation/payment backend: production RANDA.MKCOOL Supabase project

Do not create a second production app, calculator, payment route, or public copy of the calculation engine.

## Operating principles

### 1. Zero-spend automation

Repository automation must use GitHub-native/free capabilities only. Do not add a workflow that requires paid API credits, a paid domain, a paid runner, a credit-card-gated trial, or a usage-based service with automatic paid overage.

A human owner may separately decide to use a service that charges transaction fees on successful incoming payments. The repository must never create a subscription or purchase on the owner's behalf.

### 2. No automated outbound-money actions

Client code, GitHub Actions and maintenance scripts must not create refunds, payouts, transfers, purchases, subscriptions, or bank withdrawals.

The production payment provider may still apply processing fees, refunds, disputes, chargebacks, reserves or legal/regulatory adjustments. Those provider-controlled events cannot be guaranteed away by application code. Automation may report them but must not initiate them.

### 3. Secrets and private identity stay out of GitHub

Never commit:
- bank account details
- private addresses
- passwords
- Stripe secret or restricted keys
- Stripe webhook signing secrets
- Supabase service-role/secret keys
- private signing keys
- customer exports
- identity documents

Only browser-safe publishable configuration may appear in the public client.

### 4. Production changes are narrow and reversible

Automation may:
- audit
- report
- open/close GitHub incidents
- refresh generated audit reports
- update non-sensitive generated SEO metadata after validation
- propose dependency updates through pull requests

Automation must not silently change:
- £9.99 production price
- payout destination
- payment provider account
- entitlement rules
- calculation logic or coefficients
- production origins
- authentication policy
- secrets

## Daily audit

`.github/workflows/randamkcool-os-audit.yml` runs at **02:00 UTC daily** and can also be run manually.

It calls `scripts/randa_audit.py`, which checks:
- required production files
- canonical URL and paid-only markers
- approved visible price
- accidental secret patterns
- accidental PII-like literals in tracked source
- client-side refund/payout/transfer creation primitives
- live GitHub Pages availability and paid-only markers

The workflow writes `DAILY_AUDIT_REPORT.md` and opens a GitHub issue if a check fails.

## Existing production audit

`.github/workflows/production-audit.yml` remains the existing production guardrail. The RANDA OS audit supplements it rather than replacing it.

## Dependency maintenance

`.github/dependabot.yml` checks GitHub Actions dependencies weekly and creates pull requests. Never auto-merge dependency updates that can affect production without a successful audit.

## Incident priority

Treat these as P0:
1. canonical site unavailable
2. paid gate missing or bypassable
3. wrong production price
4. private calculation logic exposed publicly
5. secret/private credential committed
6. unapproved payment route or outbound-money primitive added
7. unverified domain reintroduced

Treat cosmetic issues as lower priority.

## Recovery rule

For any P0 incident, preserve evidence, stop further automated production changes, identify the last known-good commit, and follow `docs/RECOVERY-RUNBOOK.md`.
