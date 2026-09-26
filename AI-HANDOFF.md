# RANDA.MKCOOL AIM SYNC — CANONICAL AI HANDOFF

Last reconciled: **2026-09-26**

This file exists to stop ChatGPT, Gemini, Grok, builders, and other assistants from drifting into different versions of the project.

## Source of truth

- Official customer-facing app: **RANDA.MKCOOL Aim Sync v5 Paid**
- Canonical GitHub repository: **pmnow6851-cyber/Randa**
- Canonical branch: **main**
- Canonical public app: **https://pmnow6851-cyber.github.io/Randa/**
- Production hosting: **GitHub Pages**
- Production state: **LIVE_PAID_ONLY**
- Approved Aim Sync customer price: **£9.99 GBP one-time**
- Canonical operational record: **PROJECT-STATUS.md**
- Canonical social promotion control: **SOCIAL-MEDIA-CONTROL.md**
- Ready social launch queue: **SOCIAL-CONTENT-QUEUE.md**

If another handoff claims the primary repository is `Randa-aim-sync`, the production host is Vercel, there is no backend, or the calculator is a free client-only tool, treat that handoff as stale unless `PROJECT-STATUS.md` has been deliberately updated through the protected repository workflow.

## Explicitly obsolete setup instructions

Any old note, screenshot, prompt, or AI handoff that tells you to create Firebase project `RANDA-MKCOOL-CORE`, build a Firestore `User_Session` table, use Glide as the public production layer, or keep production Aim Sync logic in Bubble is obsolete and must not be executed.

Do not create a second production backend from those instructions, do not migrate production customer/payment state into them, and do not reconnect them to the official checkout or paid calculation path. They may be kept only as archive/reference material.

## Production architecture

Customer flow:

`GitHub Pages PWA → Supabase authenticated checkout → Stripe → signed Stripe webhook → verified paid entitlement → private Aim Sync calculation`

The public repository contains the customer-facing PWA shell. The private sensitivity calculation method and payment-entitlement enforcement remain server-side.

Production Supabase functions recorded by the project include:
- `create-checkout-session` — validates the signed-in account and returns the canonical payment route
- `stripe-webhook` — **single payment-to-entitlement authority** for successful payment, full refund and dispute events
- `verify-checkout-return` — safe browser return/UX redirect only; **never grants paid access**
- `calculate-aim-sync` — authenticated + active-pro protected sensitivity output
- `generate-gunsmith` — authenticated + active-pro protected Gunsmith backend
- `system-health` — public minimal health signal without exposing secrets

Do not move private calculation coefficients or payment verification logic into public browser or Android code.

## Payment control

The production Aim Sync price is **£9.99 GBP one-time**.

The obsolete **£4.99 Stripe Payment Link is inactive** and must not be treated as an official Aim Sync checkout.

The browser return URL is not proof of payment. A customer becomes entitled only after the signed Stripe webhook validates the live payment and writes the server-side entitlement. A full refund or dispute revokes access through the same signed webhook authority.

Never expose Stripe secrets, Supabase service-role credentials, bank details, passwords, private keys, tokens, signing secrets or private identity/address data in this repository or in AI handoffs.

## Paid-output boundary

Unpaid users must not receive:
- Aim Sync sensitivity matrices
- paid generated settings
- protected Gunsmith generation
- private calculation logic or coefficients

New protected tools must reuse authenticated paid entitlement rather than creating a second free-access path.

## Gunsmith expansion

The `generate-gunsmith` backend is active and protected by the paid/pro entitlement gate.

Current state:
- backend is active
- request size and per-user throttling protections exist
- generated RANDA build codes must not be presented as native CODM import codes
- customer-facing web/Android Gunsmith UI is not yet canonical production

Integrate Gunsmith only through reviewed changes that preserve the existing authentication, payment, privacy and calculation boundaries.

## Android boundary

The Flutter Android client is official source but **not yet a public Google Play production release**.

Do not publish an Android build merely because a debug APK/AAB compiles. Before public Play distribution, require the release gates in `docs/ANDROID-PLAY-RELEASE-GATE.md`, including owner-controlled signing, physical-device testing, compliant store billing/distribution, privacy/account deletion, and final signed API-36+ AAB review. The Play-channel build blocks external Stripe checkout; a native store purchase flow has not been implemented. The paid-only release has no advertising or AdMob setup requirement.

Keep the GitHub Pages app and £9.99 web route canonical until those gates are deliberately approved.

## Social promotion control

All Aim Sync social posts, profile links, organic adverts, reels, shorts and promotional CTAs must use `SOCIAL-MEDIA-CONTROL.md` as the canonical social reference and point to the single official app URL.

`SOCIAL-CONTENT-QUEUE.md` contains the prepared launch sequence. Use it as the default source for post ideas and short-form scripts unless deliberately replaced.

Because the product is **LIVE_PAID_ONLY**, do not describe the production offer as “early access”. The official app is the primary conversion CTA. **Comment “LOCK”** is secondary engagement.

Do not treat any social network as connected until provider-side connection is verified. Do not promote legacy builders, test links, custom domains, old payment links or duplicate calculators. Organic promotion is the default; paid ad spend must never be created automatically.

## Domain control

The custom domain `randa-aim-sync.com` is intentionally disabled from production until ownership and DNS are verified end-to-end.

Do not add the domain back to GitHub Pages or production origin/return allowlists until verification is complete.

## Legacy / secondary systems

Firebase experiments, Glide, Base44, Replit, Vercel experiments, Bubble builds, older AimCurve builds, calculators, spreadsheets, and other copies are not the canonical production app unless `PROJECT-STATUS.md` is intentionally changed.

Do not create a duplicate production app, duplicate Aim Sync payment path, or duplicate public calculation engine.

## Security / ownership controls

- `main` is protected by the repository ruleset: pull requests required, deletion and non-fast-forward/force-push blocked, linear history required.
- Public application tables use RLS.
- Legacy payment claims are explicitly denied to anonymous/authenticated clients and are service-side only.
- Payment helper permissions are limited to trusted server roles.
- Public source may contain only browser-safe publishable configuration, never server secrets.
- Private calculation requests include abuse/request-size controls.
- Do not weaken these controls merely to simplify a new feature.

## Change-control rules

1. Keep one canonical customer-facing Aim Sync app.
2. Keep `pmnow6851-cyber/Randa` as the front-end source of truth unless an explicit migration is approved and documented.
3. Keep production calculations private and server-side.
4. Keep the signed Stripe webhook as the sole payment-entitlement authority.
5. Never let the browser return URL or client state grant paid access.
6. Do not silently alter pricing, payout routing, entitlement rules, calculation logic, or domain ownership configuration.
7. Do not expose secrets or personal banking/private-address data.
8. Preserve free-tier/no-unnecessary-spend infrastructure where practical.
9. Treat `PROJECT-STATUS.md` as the authoritative production control record when this file and an external handoff disagree.
10. Use `.github/workflows/production-audit.yml` and the daily OS audit to detect unsafe production drift.
11. Use `SOCIAL-MEDIA-CONTROL.md` for social promotion so every channel points back to the official live app.
12. Use `SOCIAL-CONTENT-QUEUE.md` as the prepared organic content queue and never silently convert it into paid advertising.

## Current owner/provider actions

These must not be silently performed by an assistant when they affect credentials, account recovery, money routing or irreversible access:
- physically test the official app and Android client on the owner device
- create/protect Android signing material outside public GitHub
- finish Google Play billing/distribution and privacy/account-deletion gates
- review the recently authorised Supabase OAuth connection in GitHub and remove it only if it is not intentionally used for developer tooling
- verify the RANDA business email in GitHub account settings if still pending
- revoke any unused experimental API credentials directly in their provider account
- keep the custom domain disabled until registrar/DNS ownership and records are verified
- connect additional social networks before treating them as active publishing channels

## AI continuation instruction

Do not reset or rebuild the project from scratch. First read `PROJECT-STATUS.md`, `RANDA-MKCOOL-MASTER.md`, `README.md`, this file, `SOCIAL-MEDIA-CONTROL.md`, `SOCIAL-CONTENT-QUEUE.md`, and the current `main` branch before proposing or making production changes.
