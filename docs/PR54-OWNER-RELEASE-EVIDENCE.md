# PR #54 Owner Release Evidence

This file is a **redacted evidence record** for the RANDA.MKCOOL Android release gate.

It must never contain sensitivity values, calculation coefficients, formulas, access tokens, cookies, checkout/session identifiers, signing material, payout/bank details, personal addresses, private email addresses, or other credentials.

## Build identity

- Pull request: #54
- Branch: `codex/verified-config-fail-closed-20260926`
- Tested commit SHA: `________________________`
- Test date (UTC): `________________________`
- Tester: owner
- Physical Android device: `________________________`
- Android version: `________________________`

## Gate A — live paid entitlement

Use only an **existing legitimate paid entitlement**. Do not create a new payment solely for testing.

- [ ] Active entitlement is accepted.
- [ ] Requested mode returns a complete configuration.
- [ ] Complete matrix is displayed without legacy fallback.
- [ ] Inactive or invalid entitlement is denied.
- [ ] No private values or credentials were captured in public evidence.

Redacted evidence note:

```text
PASS / FAIL / NOT VERIFIED:
Evidence reference:
Notes (no private values):
```

## Gate B — physical Android behaviour

Install the exact build being evaluated and record only pass/fail evidence.

- [ ] App launches successfully.
- [ ] Paid access opens only after a successful entitlement check.
- [ ] Requested result screen renders completely.
- [ ] ONE-TAP COPY CONFIG succeeds for an authorised result.
- [ ] Copy confirmation is shown.
- [ ] Failed entitlement recheck prevents copying.
- [ ] Network loss during a required recheck fails closed.
- [ ] Entitlement revocation prevents subsequent protected access.
- [ ] If revocation/network failure happens while results are open, the next protected action is denied and stale protected data is cleared as designed.
- [ ] Relaunch after denial does not restore unauthorised protected results.

Redacted evidence note:

```text
PASS / FAIL:
Build SHA:
Evidence reference:
Notes (no private values):
```

## Gate C — store release readiness

The CI validation AAB is not proof of a signed Play Store release.

- [ ] Release signing is configured outside the public repository.
- [ ] Signing keys and passwords are not committed.
- [ ] Final signed AAB is produced by the owner-controlled release process.
- [ ] Google Play package/application identity matches the approved production identity.
- [ ] Store listing, privacy disclosures, data safety answers, and deletion/support links match actual app behaviour.

## Release decision

PR #54 remains **DRAFT / BLOCKED** until every required item above is verified.

A CI pass alone must not change this decision.

Do not merge, deploy, publish, change pricing/checkout/payouts, or expose private calculation material merely to satisfy this checklist.
