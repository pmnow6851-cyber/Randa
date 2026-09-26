# RANDA.MKCOOL Project Registry

Last reviewed: 2026-09-21

This registry defines which RANDA.MKCOOL surfaces are canonical, secondary, legacy, or out of scope. It is a control document only. It must not be used to change pricing, payouts, entitlements, secrets, authentication, production origins, or customer data.

## 1. Canonical production

### GitHub
- Repository: `pmnow6851-cyber/Randa`
- Default branch: `main`
- Role: canonical source repository
- Public deployment: GitHub Pages
- Official app: `https://pmnow6851-cyber.github.io/Randa/`

### Supabase
- Project: `RANDA.MKCOOL Aim Sync`
- Role: canonical production backend
- Expected state: healthy, protected server-side calculations, authenticated entitlement enforcement, payment/store verification, account deletion

## 2. Secondary locked builder

### Base44
- `RANDA.MKCOOL sensitivity calculator`
- Role: secondary locked builder/reference only
- Must not become a second public production app
- Must not create a free calculator or alternate payment route
- Preserve only unique design/schema work worth keeping

## 3. Legacy / retirement candidates

### Base44
- `Randa`
- four `AimCurve CODM` copy apps
- No external OAuth connectors were found during the 2026-09-21 inventory
- Each app currently has one registered app user
- Do not delete until unique data has been checked
- Do not publish or revive as customer-facing alternatives

### Replit
- `RANDA.MKCOOL AIM SYNC SYSTEM` — legacy deployment still published; retire after owner-controlled confirmation
- `Sensitivity Calculator` — not published
- `Sensitivity Configurator` — not published
- `Aim Recalibrator` — not published
- `Aim Sync Lab` — not published
- `Sensitivity Hub` — not published

These Replit projects are not approved production origins. Preserve unique source/reference material before retirement. Do not republish.

## 4. Explicitly outside the RANDA project boundary

Non-RANDA/personal or unrelated projects discovered in connected services are not to be imported, renamed, linked, or exposed through RANDA.MKCOOL systems. Personal/private identities, recovery accounts, contacts, cloud data, financial identifiers, and unrelated project content remain separate.

## 5. Protection rules

1. One official Aim Sync public route only.
2. One approved £9.99 one-time Aim Sync purchase route only.
3. Protected calculations remain server-side.
4. No public service-role keys, payment secrets, signing keys, recovery data, personal contact data, bank/payout identifiers, or customer records.
5. Public client keys are acceptable only when provider-designed for browser/mobile use and server-side authorization/RLS remains enforced.
6. No free bypass, trial, discount, duplicate checkout, DM payment route, or alternate production origin.
7. Legacy builders may be retained only as private/reference surfaces.
8. Do not delete a legacy project until unique data has been checked and a recovery path exists.
9. Never merge, deploy, change external account permissions, rotate secrets, or alter money paths automatically.
10. Non-RANDA projects remain outside the RANDA control plane.

## 6. Current owner actions

- Review and merge PR #32, then require `RANDA Production Audit Gate` in the main ruleset.
- Retire the still-published legacy Replit Aim Sync deployment after confirming no unique data depends on it.
- Keep the five unpublished Replit aim projects unpublished.
- Keep the five weaker Base44 duplicates non-production and review them only for unique data before deletion/archive.
- Keep the strong Base44 RANDA.MKCOOL builder secondary/private.
- Continue store work only through PR #23 and its release gate.
