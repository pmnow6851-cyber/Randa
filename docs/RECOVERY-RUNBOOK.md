# RANDA.MKCOOL OS — RECOVERY RUNBOOK

## Purpose

Restore the canonical Aim Sync production path after a failed deployment, broken paid gate, security incident, or unexpected configuration change without creating a second production copy.

## P0 triggers

Use this runbook immediately if any of the following occurs:
- canonical GitHub Pages app is unavailable
- paid-only gate is missing or bypassable
- displayed production price is not £9.99
- calculation coefficients or private entitlement logic appear in public client code
- a secret/private credential is committed
- an unapproved payment route appears
- client code gains refund/payout/transfer creation capability
- an unverified domain is added to production origins

## Step 1 — Freeze unsafe change

1. Do not make unrelated edits.
2. Identify the workflow run, pull request, or commit associated with the failure.
3. Preserve the failing audit report and workflow URL.
4. Do not paste secrets or customer information into GitHub issues.

## Step 2 — Confirm the last known-good state

The known-good state must satisfy all of these:
- `PROJECT-STATUS.md` says `LIVE_PAID_ONLY`
- canonical route is `https://pmnow6851-cyber.github.io/Randa/`
- public app displays £9.99 one-time
- paid gate marker is present
- no `CNAME` exists unless domain ownership/DNS has been explicitly re-verified
- private calculation logic remains server-side

Use GitHub history and successful workflow runs to identify the most recent commit that satisfies the controls.

## Step 3 — Restore narrowly

Prefer a normal revert commit or a targeted fix over destructive branch rewriting.

Do not restore old Base44, Replit, Vercel, custom-domain, free-calculator, or legacy payment-link paths as substitutes for the canonical app.

## Step 4 — Re-run audits

Run both:
- `RANDA Production Audit`
- `RANDA.MKCOOL OS Daily Audit`

A recovery is not complete until the canonical endpoint is live and both audit layers pass.

## Step 5 — Close incident

Record only:
- what changed
- why it mattered
- commit/workflow references
- fix applied
- whether paid access, security, ownership, or payment path was affected

Do not include customer PII or secrets.

## Secret leak variant

If a private credential was committed, reverting the file is not enough. Revoke/rotate the credential at the provider, then update the server-side secret store. Never add the replacement credential to GitHub.

## Payment-path variant

If the public client points to an unapproved payment route:
1. remove that route from the public client
2. restore the canonical server-created £9.99 checkout path
3. verify entitlement still requires server-verified payment state
4. confirm no legacy £4.99 payment link can unlock production access

## No autonomous financial repair

Recovery automation must never issue refunds, payouts, transfers, purchases, or bank movements. Financial incidents are reported for owner/provider handling.
