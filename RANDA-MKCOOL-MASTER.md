# RANDA.MKCOOL — MASTER SOURCE OF TRUTH

Status: ACTIVE
Last consolidated: 2026-09-10

This document is the single operational summary for RANDA.MKCOOL Aim Sync. Detailed specialist documents may remain in the repository for reference, but when instructions conflict, this file and `PROJECT-STATUS.md` govern current operations.

## 1. Canonical product

- Product: **RANDA.MKCOOL Aim Sync v5 Paid**
- State: **LIVE_PAID_ONLY**
- Official app: `https://pmnow6851-cyber.github.io/Randa/`
- Canonical repository: `pmnow6851-cyber/Randa`
- Customer price: **£9.99 GBP one-time**
- No free calculator access or free sensitivity outputs.
- Do not publish a second live customer build or alternate checkout path.

## 2. Customer funnel

Use one simple path:

**Winning CODM proof → curiosity → official RANDA.MKCOOL app → £9.99 unlock → paid Aim Sync profile**

Primary conversion CTA: **Open the official app**.

Secondary engagement CTA: **Comment “LOCK”**.

Do not describe the live product as “early access”.

## 3. Product promise

Core message:

**Your aim isn’t bad. It’s unsynced.**

Sell the outcome, not the method. Approved outcome language includes smoother tracking, steadier control, a repeatable setup and less sensitivity guesswork.

Do not claim guaranteed wins, kills, rank gains or other guaranteed performance.

## 4. Paid product architecture

- GitHub Pages is the canonical public front end.
- Supabase is the private production backend.
- The sensitivity calculation engine remains private in the `calculate-aim-sync` Edge Function.
- The public front end must never contain private calculation coefficients or the proprietary calculation method.
- Paid entitlement must come only from server-verified Stripe payment state.
- A fully refunded payment must not retain paid access.

## 5. Payment rules

- Use the single active **£9.99 GBP one-time** Stripe offer.
- Do not reactivate old prices or payment links.
- Do not add a second customer payment route without an explicit owner decision.
- Never place bank details, private payment credentials, Stripe secret keys or recovery data in public source code.

## 6. Growth system

Prioritise growth work in this order:

1. Keep the live product reliable on mobile.
2. Verify the payment and entitlement flow.
3. Capture genuine winning CODM gameplay proof.
4. Publish short-form content consistently.
5. Improve conversion from social traffic to the official app.
6. Automate repetitive work only after the funnel works reliably.
7. Add new product features only when they clearly improve conversion, retention or product quality.

Default effort allocation:

- **70%** product reliability, funnel and conversion
- **20%** genuine proof and organic content
- **10%** new tools, experiments and features

## 7. Social content rules

Use genuine winning gameplay, victory screens and strong before/after outcome footage.

Every short should:

- use a hard hook in the first second
- call out a common sensitivity mistake
- show a visible aiming/tracking outcome
- tease Aim Sync without revealing the calculation method
- point viewers to the official app
- optionally use “Comment LOCK” for engagement

Do not publish:

- weak or mediocre gameplay as proof
- raw screenshots containing private profile information
- generated artwork presented as genuine gameplay evidence
- exact proprietary calculation logic
- exact paid-output values as promotional giveaways
- unsupported guarantees

## 8. Platform control

Only publish or automate through accounts that are verified as connected and controlled by the owner.

Do not assume a social platform is connected because an old build, service or document mentions it.

Use the official app URL only in public promotion.

No paid boosts or ad spend unless the owner explicitly changes the no-spend rule.

## 9. Security and ownership

- The repository owner retains sole control of production decisions.
- Keep `main` protected against deletion and force-pushes.
- Use pull requests for controlled changes.
- Keep personal/private identity data separate from public RANDA.MKCOOL assets.
- Never commit passwords, recovery codes, service-role keys, API secrets, private bank details or private addresses.
- Keep experimental OpenAI/API credentials out of the production app.
- Keep unverified domains disabled until DNS and ownership are verified end-to-end.
- Keep legacy Base44/Replit builds archive-only unless deliberately reactivated by the owner.

## 10. What to ignore

Do not chase tools, integrations or AI features simply because they are new.

Ignore anything that does not materially improve at least one of these:

- product reliability
- security
- customer proof
- traffic
- conversion
- retention
- operational efficiency

## 11. Current success definition

RANDA.MKCOOL is succeeding when:

- the official app works reliably on mobile
- the single £9.99 payment path works end-to-end
- paid customers receive access correctly
- no free or legacy route leaks paid outputs
- genuine winning proof is published consistently
- social traffic reaches the official app
- private identity, payment and calculation assets remain protected

## 12. Change-control rule

Never silently change pricing, payment destination, entitlement policy, calculation logic, ownership controls or canonical production URL.

Any proposed change to those areas must be deliberate, reviewable and traceable through the protected repository workflow.
