# Security Policy

RANDA.MKCOOL keeps public source, private identity, account recovery, and payout information strictly separated.

## Public repository rules

- Never commit passwords, API secrets, private keys, recovery codes, bank details, identity documents, private email addresses, customer private data, or provider recovery information.
- Keep payout destinations, refunds, transfers, purchases, subscriptions, account ownership changes, and credential changes inside the relevant provider's authenticated dashboard.
- Production changes must go through the protected `main` workflow and remain under the repository owner's control.
- Security audit output containing sensitive provider or account details must not be published in this repository.

## Reporting a security issue

Do not post secrets or personal information in a public GitHub issue. Report only the minimum public-safe technical detail needed to identify the affected code or behavior.

## Production principle

The canonical RANDA.MKCOOL deployment must preserve the approved paid production state, privacy boundary, and owner-controlled change process.
