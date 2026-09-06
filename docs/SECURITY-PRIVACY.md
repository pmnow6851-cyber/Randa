# RANDA.MKCOOL OS — SECURITY & PRIVACY

## Goal

Protect the production Aim Sync app, private calculation engine, payment entitlement path, owner identity, and customer data while keeping the public GitHub repository safe to inspect.

## Public repository boundary

This repository is public-facing application code and operations documentation. It must contain **no private owner identity records, bank details, home addresses, identity documents, passwords, private keys, customer exports, or privileged provider credentials**.

## Authentication and payment reality

The current production app uses Supabase authentication and Stripe payment verification. This means customer email/account and payment information may be processed by those providers as necessary to authenticate users and process payments.

Therefore, the project must not claim that absolutely no personal data is ever processed anywhere. The enforceable rule is:

- do not store customer PII in GitHub
- do not write customer PII to public audit logs
- collect only data necessary for authentication/payment/service delivery
- keep privileged access server-side
- apply least privilege and provider-native access controls
- do not export customer data into maintenance automation

If the product is later redesigned for anonymous-only access, treat that as a separate security/entitlement architecture project rather than silently removing authentication from the live paid app.

## Secrets policy

### Allowed in public client

Only browser-safe publishable configuration that is designed to be exposed to end users.

### Forbidden in public client or GitHub

- Stripe secret keys (`sk_*`)
- Stripe webhook signing secrets (`whsec_*`)
- Supabase service-role/secret keys
- private JWT signing secrets
- bank credentials
- passwords
- recovery codes
- API tokens capable of refunds, payouts, transfers or account administration

## Payment safety policy

The application and repository automation must not contain code that initiates:

- refunds
- payouts
- transfers
- purchases
- subscriptions on behalf of the owner
- withdrawals from a bank account

Payment-provider fees, disputes, chargebacks, reserves, mandatory refunds, tax obligations, or regulator/provider actions are outside the application's control and must not be misrepresented as impossible.

## Logging policy

Allowed logs:
- timestamp
- anonymized technical request/event ID
- success/failure state
- endpoint health
- build SHA
- non-sensitive error category

Do not log:
- full email addresses
- passwords
- card data
- bank details
- postal addresses
- authentication tokens
- Stripe secret objects
- Supabase service-role data

## Privacy audit boundary

`scripts/randa_audit.py` scans the repository for PII-like literals and high-risk secret patterns. It deliberately does not download the production customer database.

Database privacy controls should remain server-side. Any future server-side privacy scanner must:
1. run inside the trusted backend boundary
2. use the least privilege necessary
3. avoid exporting raw matches to GitHub
4. return counts/status only where possible
5. require manual review before deleting legitimate customer records

Automatic deletion based only on regex matches is forbidden because it can destroy valid data.

## Incident response

If a secret is committed:
1. treat the secret as compromised even if the commit is reverted
2. revoke/rotate it at the provider
3. remove it from active code
4. investigate repository history and logs
5. open a GitHub incident without pasting the secret into the issue

If private customer data is exposed, do not copy it into an issue. Record only the affected system, approximate scope, timestamps, and remediation steps.

## Production change authority

Automated jobs may audit and report. They may not autonomously change pricing, payout destinations, calculation logic, entitlement policy, authentication policy, production origins, or provider secrets.
