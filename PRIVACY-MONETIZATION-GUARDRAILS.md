# RANDA.MKCOOL PRIVACY + MONETIZATION GUARDRAILS

Status: ACTIVE — PROJECT-WIDE
Last aligned: 2026-09-07

## Purpose

Keep every RANDA.MKCOOL business, app, automation, monetization experiment and future AI venture operationally separate from the owner's private life while allowing approved project systems to earn legitimate revenue.

This policy applies to Aim Sync, Mining Hub, AI lead/deal engines, property/commission concepts, future SaaS products, social channels, repositories, cloud storage, payment integrations and any connected automation.

## Core security model

**Public/project zone → controlled business integrations → private owner zone**

Data may move from the public/project zone into approved business systems only when needed to operate the project. Private-owner information must not flow back into public/project assets except where a trusted provider privately requires it for identity verification, tax, security, KYC or payouts.

## Non-negotiable privacy boundary

Public RANDA.MKCOOL assets must never expose:

- home address or postcode
- private email or recovery email
- private phone number
- personal social accounts or private contacts
- bank account details, payout identifiers or financial statements
- passwords, passkeys, backup codes or recovery codes
- API secrets, service-role keys, webhook secrets, access tokens or signing keys
- identity documents or verification records
- personal family, health, benefits, correspondence or unrelated private records
- private cloud-drive content, private photos, private backups or private account-recovery information

Only the RANDA.MKCOOL brand, approved public product URLs, approved business contact points and approved public social identities belong in customer-facing material.

Any screenshot, export, recording, log or media asset containing private information must be redacted or excluded before publication.

## Account ringfence

1. Use dedicated RANDA.MKCOOL identities for public-facing social, support, repository, marketing, analytics and business operations wherever the provider permits.
2. Keep personal accounts for personal/private activity only.
3. Do not use personal recovery addresses, personal phone numbers or private contact lists in public project metadata.
4. Project automations must not browse, copy, summarize, publish, transfer or modify unrelated private-account data.
5. Access private data only when the owner has requested a task that genuinely requires it, and expose the minimum necessary information.
6. Never sync an entire personal mailbox, drive, photo library or contact list into a public RANDA.MKCOOL datastore.
7. Keep business exports and backups separate from personal backups.

## AI/autonomy boundary

AI may autonomously perform low-risk project work such as:

- analyse public/project data
- draft content and code
- monitor public endpoints
- detect errors, downtime and anomalies
- prepare reports and recommendations
- organise project files
- operate approved no-spend workflows
- track inbound revenue events and project performance

AI must not autonomously:

- withdraw, transfer or send money
- purchase products, services, ads, subscriptions or crypto
- start trials that can convert to paid plans
- change bank payout destinations
- reveal or publish private data
- expose credentials or secret algorithms
- delete personal data or accounts
- merge personal and project identities
- grant third parties access to private accounts
- enter loans, mortgages, credit agreements, investments or property contracts
- execute regulated property, financial or legal transactions without required human/professional controls

## £0 outbound-cash rule

Project-controlled discretionary spend is **£0** unless the owner explicitly changes this rule for a specific transaction.

Allowed:

- free/open-source tools
- free hosting/free tiers within stated limits
- organic social distribution
- free analytics and scheduling within plan limits
- legitimate inbound payments, commissions, affiliate revenue, creator revenue and payouts

Blocked unless explicitly approved for that specific case:

- paid ads or boosted posts
- paid creator/business tools
- subscriptions or trials with future charges
- hardware purchases
- investment deposits
- crypto purchases
- automatic outbound marketing payments
- any autonomous bank/card expenditure

Provider fees, refunds, chargebacks, taxes and statutory obligations remain governed by provider rules and law and must not be misrepresented as avoidable or guaranteed-zero costs.

## Revenue boundary

Preferred pattern:

**Audience / lead / buyer intent → approved RANDA.MKCOOL product or marketplace → legitimate transaction or referral → approved payment/payout provider → business payout destination**

Revenue systems may track inbound amounts and conversion events, but must never expose banking credentials publicly or make unsupported claims of guaranteed income.

## Property, lead and commission systems

For AI deal-matching, property, recruitment, affiliate or commission concepts:

- disclose commercial/referral relationships where required
- use compliant terms and consent flows
- do not impersonate regulated professionals
- do not promise guaranteed returns
- do not advertise government schemes as guaranteed profit
- separate lead qualification from regulated financial/legal advice
- require human/professional review where law or provider rules require it
- keep customer personal data out of public repositories and social assets

## Code and secrets

1. No private secrets in GitHub, client-side JavaScript, screenshots, documentation or social posts.
2. Client-safe publishable keys may be used only when designed by the provider to be public and protected by server-side authorization/RLS.
3. Service-role/admin keys and signing secrets must stay server-side.
4. Payment entitlement and proprietary calculation logic should remain server-side when secrecy matters.
5. `.gitignore` is a guardrail, not a substitute for secret scanning and least-privilege configuration.
6. If a real secret is ever committed, treat it as exposed and rotate/revoke it rather than merely deleting the file.

## Publication gate

Every public post, page, repository change or media asset must pass these checks:

1. No private owner data visible.
2. No private credentials, recovery data or financial data visible.
3. No secret formulas, internal coefficients or protected business logic visible.
4. No customer personal data visible.
5. Only approved public RANDA.MKCOOL identities and URLs are promoted.
6. No unverified platform connection or revenue result is claimed.
7. No paid boost/spend is enabled without specific owner approval.
8. Claims are truthful and do not imply guaranteed earnings, investment returns or government-backed profit.
9. Product/platform affiliation disclaimers are used where appropriate.

## Storage and retention

- Keep only data needed for a defined project purpose.
- Prefer anonymised or aggregated analytics where possible.
- Do not retain identity documents or financial records in public/project repositories.
- Keep sensitive provider/KYC records inside the provider that requires them whenever possible.
- Remove unnecessary exported copies after their operational purpose ends.

## Incident rule

If private data, credentials or payout information appears in a public asset:

1. Stop publication/access where possible.
2. Revoke or rotate exposed credentials immediately.
3. Remove the exposed material from active public locations.
4. Review logs and connected services for misuse.
5. Restore only after the affected boundary is secured.
6. Record the incident without reproducing the secret itself.

## Operating principle

**RANDA.MKCOOL can be highly automated. Personal life cannot become its database.**

Automation receives the minimum access required for the current business task, while private identity, recovery, banking and unrelated personal data stay ringfenced.
