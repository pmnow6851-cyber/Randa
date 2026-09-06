# RANDA.MKCOOL AIM SYNC — CANONICAL AI HANDOFF

Last reconciled: 2026-09-06

This file exists to stop ChatGPT, Gemini, Grok, builders, and other assistants from drifting into different versions of the project.

## Source of truth

- Official customer-facing app: **RANDA.MKCOOL Aim Sync v5 Paid**
- Canonical GitHub repository: **pmnow6851-cyber/Randa**
- Canonical branch: **main**
- Canonical public app: **https://pmnow6851-cyber.github.io/Randa/**
- Production hosting: **GitHub Pages**
- Production state: **LIVE_PAID_ONLY**
- Approved customer price: **£9.99 GBP one-time**

If another handoff claims the primary repository is `Randa-aim-sync`, the production host is Vercel, there is no backend, or the calculator is a free client-only tool, treat that handoff as stale unless the repository's `PROJECT-STATUS.md` has been deliberately updated to say otherwise.

## Production architecture

Customer flow:

`GitHub Pages PWA → Supabase → Stripe Checkout → verified paid entitlement → private Aim Sync calculation`

The public repository contains the customer-facing PWA shell. The private sensitivity calculation method and payment-entitlement enforcement remain server-side.

Production Supabase functions recorded by the project include:

- `create-checkout-session`
- `verify-checkout-return`
- `calculate-aim-sync`
- `system-health`
- `stripe-webhook` as a secondary event handler

Do not move private calculation coefficients or payment verification logic into public browser JavaScript.

## Payment control

The production Aim Sync price is **£9.99 GBP one-time**.

A legacy **£4.99 Stripe Payment Link** may still exist in Stripe, but it is not part of the production unlock path and must not be treated as official Aim Sync checkout.

Never expose Stripe secrets, Supabase service-role credentials, bank details, passwords, private keys, tokens, or private identity/address data in this repository or in AI handoffs.

## Domain control

The custom domain `randa-aim-sync.com` is intentionally disabled from production until ownership and DNS are verified end-to-end.

Do not add a GitHub Pages `CNAME` file or add that domain back to production origin/return allowlists until verification is complete.

## Legacy / secondary systems

Base44, Replit, Vercel experiments, older AimCurve builds, calculators, spreadsheets, and other copies are not the canonical production app unless `PROJECT-STATUS.md` is intentionally changed.

Do not create a duplicate production app, duplicate payment path, or duplicate public calculation engine.

## Change-control rules

1. Keep one canonical customer-facing app.
2. Keep `pmnow6851-cyber/Randa` as the front-end source of truth unless an explicit migration is approved and documented.
3. Keep production calculations private and server-side.
4. Do not silently alter pricing, payout routing, entitlement rules, calculation logic, or domain ownership configuration.
5. Do not expose secrets or personal banking/private-address data.
6. Preserve free-tier/no-unnecessary-spend infrastructure where practical.
7. Treat `PROJECT-STATUS.md` as the authoritative production control record when this file and an external AI handoff disagree.
8. Use `.github/workflows/production-audit.yml` to detect unsafe production drift.

## Current external actions still requiring provider-side control

- Deactivate the legacy £4.99 Stripe Payment Link when Stripe Payment Link write access is available.
- Revoke any unused experimental OpenAI API key directly in the OpenAI Platform account.
- Keep the custom domain disabled until registrar/DNS ownership and records are verified.

## AI continuation instruction

Do not reset or rebuild the project from scratch. First read `PROJECT-STATUS.md`, `README.md`, this file, and the current `main` branch before proposing or making production changes.
