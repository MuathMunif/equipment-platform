# Release gate — not yet satisfied
All initial items below are unchecked. A documentation handoff is not a production release.

- [ ] Core V1 tasks and accepted UX complete; optional contract scope resolved rather than invented.
- [ ] No GPS, forced company onboarding, duplicate invoices or false profit labels.
- [ ] Exact money, allocation rounding, settlement races/idempotency, review exclusion and refund semantics tested.
- [ ] Tenant/action/resource access tested across every API, aggregate, notification and original shared attachment.
- [ ] OTP live provider configured; dev bypass/seed/scanner substitutes cannot enable in production.
- [ ] Secure sessions, phone change/recovery, membership removal and approved account/workspace deletion policies tested.
- [ ] Private file upload/quarantine/validation/scan/read workflow tested with real chosen storage integration.
- [ ] Hosted provider/region/costs and data-handling/retention decisions approved by owner; no invented compliance claim.
- [ ] Database migrations and rollback/recovery strategy tested without destructive production recreation.
- [ ] Backup and restore drill covers database plus file bytes, with RPO/RTO agreed.
- [ ] Notification schedules/retries/dedup/renewal/archive/revocation tested; native/browser permissions honestly reported.
- [ ] Android and iOS/web build and device behavior validated on available supported environments; gaps explicit.
- [ ] Error/loading/empty/offline/expired-session paths and Arabic keyboard/RTL accessibility reviewed.
- [ ] Logs/monitoring are useful and avoid secrets and unnecessary personal content.
- [ ] Secrets scanning and dependency/security checks reviewed; significant findings fixed or explicitly accepted.
- [ ] Owner UAT on a separate staging environment completed.
- [ ] Product name, store accounts/publishing IDs, privacy/support/account-deletion information finalized.
- [ ] Explicit owner approval obtained before any public deployment, publishing or real paid-service activity.
