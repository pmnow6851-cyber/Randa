# RANDA.MKCOOL Brand Identity & Privacy Guardrails

This file is the public source of truth for the RANDA.MKCOOL project identity.

## Canonical public identity

- Brand: **RANDA.MKCOOL**
- Product: **RANDA.MKCOOL AIM SYNC**
- Public app: **https://pmnow6851-cyber.github.io/Randa/**
- Customer support: **randamkcool.systems@gmail.com**
- Public social display name: **RANDA.MKCOOL**
- Public social handle target: use the closest available form of **@RandaMkCool** consistently across platforms.

## Public profile rules

- Use the same RANDA.MKCOOL brand avatar across business social accounts.
- Do not use a personal portrait as the public business avatar.
- Do not publish private phone numbers, home addresses, personal email addresses, recovery addresses, banking details, passkeys, recovery codes, or account-security answers.
- Customer contact must go through the business support address or the official support page.
- Keep personal social accounts separate from RANDA.MKCOOL business accounts.

## Ownership separation

- Legal identity may be supplied privately to regulated services that require verification.
- Legal/private verification details must not be copied into public profiles, repository files, marketing posts, or customer support pages.
- Payment processors may hold the private payout destination. The app, repository, social accounts, analytics tools, and content systems must never receive online-banking credentials.

## Repository privacy

- Do not commit personal email addresses, phone numbers, home addresses, passwords, API secrets, Stripe secret keys, service-account keys, signing keys, customer data, or recovery codes.
- Local Git clients should use a GitHub-provided `users.noreply.github.com` commit email where practical.
- Keep GitHub email privacy enabled for future commits.
- Existing history must not be force-rewritten without a verified backup and deployment check.

## Brand consistency

Public-facing text should use **RANDA.MKCOOL** rather than personal names or inconsistent variants. The product should be called **RANDA.MKCOOL AIM SYNC** or **Aim Sync** where space is limited.

## Money path

The intended commercial flow is one-way:

**Customer -> RANDA.MKCOOL -> regulated payment processor -> private payout account**

No public or project system should be given credentials that allow access to the private payout account.

## Change rule

Any change to public brand identity, official app URL, support address, payment route, or ownership structure should be reviewed against this file before release.
