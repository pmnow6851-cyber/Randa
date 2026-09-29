# PR #54 — minimum redacted owner evidence

**Decision: DRAFT / BLOCKED.** A CI pass is evidence for the checks it ran, not live paid-service or physical-device certification. No owner test below has been observed in this record.

## Candidate identity

- PR: #54.
- Tested PR head: [full commit SHA].
- Workflow run and job: [run URL / job ID].
- Artifact: [name / ID]; installed file: [APK or Play-delivered release].
- Actual CI checkout: [full commit SHA]; source tree matches tested head: [YES / NO / NOT VERIFIED].
- Distribution channel: [Google Play / other]; evidence from another channel does not establish the Play checkout boundary.
- Test date/time and timezone: [ ]; tester: owner.
- Physical device / Android version: [ ]; test environment: [live / isolated non-production, no URL].
- Final signed release version tested: [NOT VERIFIED until observed].

CI may check out a temporary PR merge commit. Verify its source tree or exact relevant diff before tying its artifact to the PR head. A temporary CI merge is not a production merge. An artifact ZIP digest is not the extracted APK hash; record an APK hash only if actually calculated.

## Minimum outstanding cases

Every row needs a date/time, observed outcome and private evidence reference. Keep actual account identifiers, responses and configuration values out of this file.

| ID | Action and required observation | Status | Date/time / redacted outcome / evidence ref |
| --- | --- | --- | --- |
| E1 | Existing legitimate paid identity, online: live service accepts access and returns a complete configuration for every requested mode and all four sensitivity sections. Privately check named scopes, required vertical row, validity and absence of missing/duplicate/substituted rows or legacy fallback. | NOT VERIFIED | [ ] |
| E2 | Existing inactive/unentitled identity and missing/invalid authentication: service denies protected output; phone cannot open paid results or copy them. A client-only lock does not prove server denial. | NOT VERIFIED | [ ] |
| E3 | Physical Android, existing paid identity: open complete results and use ONE-TAP COPY CONFIG. Clipboard marker is replaced; copied labels and values match the live/displayed result privately; confirmation appears. Verify both modes, then MP-only and BR-only exclude the other mode from display and copy. | NOT VERIFIED | [ ] |
| E4 | Physical Android, disconnected before protected access: entry/copy is denied, with no new paid result, clipboard write or copy-success message. | NOT VERIFIED | [ ] |
| E5 | Open paid result online, disconnect mobile data and Wi-Fi, then copy or refresh access: denial clears result and home preview, closes result screen, leaves the clipboard marker unchanged and gives no copy-success message. Record the triggering action and elapsed time. | NOT VERIFIED | [ ] |
| E6 | On an isolated reversible test entitlement, open results, revoke test access, then copy or refresh: the same denial/clear/close/unchanged-clipboard behaviour occurs. Restore only the test entitlement afterwards. Record server denial and test restoration. | NOT VERIFIED | [ ] |

For E1, the current response contract requires each requested MP/BR mode to contain the nine named scopes plus Vertical Turning Sensitivity in camera, firing, gyroscope and gyroscope-firing. The supported OFF representation in gyroscope rows is valid. Record only completeness and private value comparison as MATCH / MISMATCH; do not record values. Record the gyroscope selection tested. One selection does not verify every selection.

For E2 and E4-E6, relaunch while the same denied/offline condition persists: protected results must not reappear without a successful fresh access check. Mark each variant separately in the evidence note. A both-mode test cannot prove exclusion of an unrequested mode.

Before each case, place harmless text such as RANDA TEST E5 on the clipboard and verify it. For E5/E6, do this before opening the result. Privately inspect the clipboard promptly; if Android expiry or another app changed it, rerun with a fresh marker. A success message alone does not prove copying. Erasing an already copied export is not demonstrated by revocation.

The result screen is not continuously rechecked while idle. E5/E6 must trigger the next protected action or access refresh; record actual timing. Do not claim immediate removal at the instant connectivity or entitlement changes.

## Preconditions and redaction

- Use existing legitimate paid access; no purchase, refund, dispute, production entitlement edit or access bypass to manufacture evidence.
- E6 requires an isolated test environment exercising the same client access checks. Without it, retain NOT VERIFIED. A widget test is not a substitute for physical revocation evidence.
- Record installation failure as BLOCKED; do not uninstall the working app or erase its data solely to force installation.
- Evidence references are owner-controlled local labels, not public uploads or signed links.
- Exclude formulas, sensitivity values, raw responses, clipboard payloads, credentials, tokens, cookies, private configuration/URLs, signing material, account IDs and personal/financial data.
- Use PASS only for observed expected behaviour; FAIL for an observed defect; NOT VERIFIED for missing prerequisites/evidence; NOT RUN for a case not attempted. Any non-PASS blocks release.

## Separate Play publication gates

These remain unverified until checked in the owner-controlled release and Play Console:

- Eligible verified Play developer account and production access; applicable closed-testing and device-verification requirements completed. No registration payment under the current zero-spend rule.
- Deliberately approved distribution/monetisation route. The Google Play channel blocks external Stripe checkout and has no native purchase implementation. Existing-paid-account access is not proof of a working in-app sales route.
- Owner-controlled signing, verified final signed AAB, package/version identity and final release-device tests. The unsigned CI AAB is not a submission artifact.
- Privacy/Data safety, working account deletion, reviewer app access, content rating, listing, support contact and original/licensed assets checked against the submitted build.
- Backend authorisation, payment-to-entitlement and revocation evidence; dependency/security findings resolved or explicitly assessed.

Completing the six cases does not satisfy these separate publication gates. Keep PR #54 draft while evidence is incomplete; do not merge or publish solely to turn a checklist green.
