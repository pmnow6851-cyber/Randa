# RANDA.MKCOOL Security & Revenue Path Audit — 25 September 2026

Public-safe audit record. No customer secrets, personal identity data, bank details, payment credentials, recovery data, or private signing material are recorded here.

## Result

Current Aim Sync production architecture is materially aligned with the RANDA.MKCOOL operating constitution.

### Payment path

- Canonical Aim Sync offer is active at £9.99 GBP one-time.
- The obsolete £4.99 Aim Sync payment route is inactive.
- Checkout is generated only after signed-in user validation.
- Successful entitlement is granted only by the signed Stripe webhook.
- The browser return route is UX-only and cannot grant paid access.
- Refund/dispute handling can revoke the entitlement.
- A recent owner test did not complete because payment authentication was declined by the payment network/issuer path. This was not an entitlement bypass or a secret leak.

### Supabase

- Production project reports ACTIVE_HEALTHY.
- Security advisor currently reports no security lints.
- Row Level Security is enabled on all public application tables.
- Entitlements are readable only by the owning authenticated user.
- Purchase claims deny direct anonymous/authenticated client access.
- Publishable client configuration is separated from privileged service-role material.
- Webhook signing secret and service-role credentials remain server-side.

### Public app / privacy

- Public buyer pages expose product information and the approved business support contact only.
- No home address, bank information, private recovery data, signing material, or privileged backend secret is intentionally published.
- The current public host is GitHub Pages. It is secure enough for the present free-first deployment, but it reveals the GitHub hosting identity in the URL.
- A verified branded domain or privacy-separated hosting hostname would improve presentation and developer separation. Do not reactivate an unverified domain.

### Native store safety

- Android release-signing support is owner-controlled and secrets remain outside Git.
- Store builds must not accidentally ship the direct Stripe checkout route.
- `RANDA_DISTRIBUTION_CHANNEL` now provides a compile-time safety gate:
  - `direct`: authenticated Stripe web checkout allowed.
  - `google_play`: external Stripe checkout blocked.
  - `app_store`: external Stripe checkout blocked.
- Native store purchase flows still require final store-side configuration and end-to-end testing before publication.

## Remaining gates

- Generate and commit a reviewed iOS platform wrapper before claiming iOS release readiness.
- Implement and test native Google Play and App Store purchase UI against the existing server verification boundary.
- Verify Android/iOS physical-device purchase restoration.
- Replace the public GitHub-host identity only after a new hostname is genuinely controlled and verified.
- Add optional AI functionality only through a server-side provider adapter with cost/privacy limits.
