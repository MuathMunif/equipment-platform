# Technical implementation baseline
Status: BASELINE for broader architecture; current M0/M1/M2 local implementation is described below and in HANDOFF.

# تنفيذ M2 المحلي بتاريخ 2026-09-24: PostgreSQL/Flyway V1–V9، تطبيق Flutter، وتخزين ملفات تطويري محلي خلف ObjectStorageService. V6 expense_allocation يحفظ أصل المصروف الواحد، وV7 DRAFT/DISCARDED تستكمل الصف نفسه مع مرفقاته، وV8 ينظف الملفات المحلية المؤقتة القديمة في dev فقط، وV9 يقوي شكل السجل المنشور. بحث السجل محدود الصفحات (30). التخزين S3 الخاص والفحص الإنتاجي المذكوران أدناه خط أساس معماري ولم يُنفّذا بعد.
Use the owner's confirmed business rules unchanged. Record reversible implementation choices in ADRs;
escalate changes to business meaning, authorization, paid providers, or data handling.

## A-01 — Repository and deployment shape
One repository: `backend/`, `app/`, `infra/`, `contracts/`, `docs/`, `design/`.
Flutter application targets Android, iOS and browser; responsive/adaptive layouts, shared business flows.
Java Spring Boot REST API, a modular monolith deployed as one application initially.
PostgreSQL as authoritative relational data store. Private S3-compatible object storage for attachment bytes.
Production favors managed PostgreSQL and managed object storage; no provider, account, region or tariff has been chosen.
Do not use Firebase as the business database merely because FCM is proposed for push notifications.
Do not introduce microservices, Kafka/RabbitMQ, Redis, Kubernetes, event sourcing, or a custom AI orchestrator by default.

## A-02 — Framework/toolchain selection
Inspect the actual host OS, CPU, installed Java, Maven, Flutter/Dart, Git, Docker and platform SDKs.
Use currently supported stable and mutually compatible versions verified from official documentation.
Record versions and source/check date in `docs/ENVIRONMENT.md`, then pin dependencies/toolchains and lockfiles where appropriate.
Never invent an installed version, a successful build, a container runtime, an emulator, an Apple signing team or cloud credentials.
Use a Maven wrapper after choosing a compatible build; migrations such as Flyway are a proposed default, not an existing setup.
Flutter state-management/router/HTTP packages are bounded implementation choices: pick a small maintained set, document why,
and test Arabic/web/mobile compatibility. Do not turn this choice into weeks of architecture discussion.
Spring Modulith can assist module checks; use only if it materially helps. Package-by-feature boundaries are required regardless.

## A-03 — Module boundaries
identity: OTP challenges, verification, user account, sessions, phone changes.
workspaces: ownership, memberships, invitations, roles and scope; optional organizations.
equipment: assets, internal reference, optional data, archive state and driver-assignment history.
finance: original entries, allocations, settlements, linked refunds, review state and audit integration.
maintenance: issues and operational history; links to finance, not duplicate money records.
documents: types, current version, prior versions, expiration and renewal.
attachments: metadata, upload authorization, quarantine, validation, linking and read authorization.
notifications: in-app inbox, preferences, scheduled reminders and durable dispatch.
projects: optional association/contracts; only specified functionality, no invented full contracting system.
audit: actor, resource, tenant, action and meaningful before/after changes.
Controllers/services/repositories live within features. Do not expose persistence entities directly as API contracts.

## A-04 — Proposed data concepts (not finalized DDL)
User; OtpChallenge; Session; Workspace; Membership; Invitation; MembershipScope; Organization;
Equipment; DriverAssignment; FinancialEntry; EntryAllocation; Settlement; Refund;
Issue; IssueEvent; Document; DocumentVersion; Attachment; AttachmentLink;
Notification; ScheduledReminder; OutboxEvent; AuditEvent; IdempotencyRecord.
Use only entities needed by the current slice; keep future concepts documented instead of creating unused scaffolding.
An equipment display reference is unique within its workspace and is not an authorization secret.
Model is a minimally constrained text input pending any explicit decision to split model designation/year.
Do not require an organization foreign key for tenant ownership. A project is not the data-isolation boundary.

## A-05 — Tenant and resource authorization
Every tenant-owned row carries an unambiguous workspace owner; queries, joins and foreign references enforce same-workspace links.
Authorize the authenticated actor's active membership plus allowed action and resource scope, including archived records,
attachments, review queues, lookups, dashboard aggregates, pagination counts and notification deep links.
A client-supplied workspace identifier is selection, not proof of membership.
Check access before cache/idempotency replay returns a previously stored response. Never expose another tenant's metadata.
Database composite foreign keys/constraints should guard tenant consistency where practical; application checks remain mandatory.
RLS can be defense-in-depth if correctly tested with pooled connections; do not claim it is active without policy/role tests.
Revocation must affect continued access, not just hide a button after the next login.
A driver cannot self-grant a role, approve their own submission by changing request fields, or read global financial data.
A multi-equipment original attachment needs full authorization over all exposed equipment/financial content.
Showing an allowed allocation does not automatically authorize showing the shared total, parties, original invoice or other shares.

## A-06 — Financial correctness
Use BigDecimal/decimal server arithmetic and exact PostgreSQL NUMERIC/DECIMAL or a documented exact minor-unit representation.
JSON money should be decimal strings with a single documented precision/scale contract; Flutter web must not decide totals with binary floats.
Currency baseline is SAR, scale two; choose maximum amount and validation limits explicitly, not infinite or silently truncated values.
Separate entry lifecycle (draft/pending/posted/cancelled), settlement status (unpaid/partial/paid), upload state, and issue state.
A settlement belongs to one entry. A shared expense has allocations whose sum equals its total.
A complete-payment shortcut creates the original and its valid initial settlement atomically, not two independent financial entries.
Protect settlement creation and entry edits against concurrent requests: lock/version/conditional update with tests.
Do not allow two concurrent last-balance payments to overpay; do not rely on UI disabling for correctness.
Use scoped idempotency keys for entry creation, settlement creation, submission/approval and upload finalization where appropriate.
Define replay/payload-conflict behavior. A retried save after a lost response returns the same authorized result, not a duplicate.
Recognized totals exclude draft/pending/cancelled entries. Settlement dates determine actual cash-period views.
A pending submission may record what the driver reports paying, but is not included in recognized financial totals until approval.
Distinguish operation date (business date), settlement date (cash date), created_at (instant), and optional due date.
Proposed timezone baseline: Asia/Riyadh business dates; store instants consistently, document date-boundary conversions.
Do not retrospectively rewrite historical allocations or settlement snapshots on an ordinary edit.
Shared settlement allocation uses the confirmed original proportions, with a deterministic minor-unit reconciliation rule.
Test cumulative allocation across many tiny settlements, final exact exhaustion, stable ties and refunds.
Record the rounding policy before implementing it; it must preserve original total and each share at full settlement.
Refund cash movement must reference the original. Effect on the underlying amount owed is an OPEN business question.
Never reopen a receivable/payable or write it off silently simply because money was returned.

## A-07 — API contracts
Use a versioned REST namespace, an OpenAPI contract and one consistent error schema with stable machine codes and Arabic UI mapping.
Define request/response types before parallel frontend/backend work. No mock contract that differs from the real server.
Specify optional fields, money serialization, dates, idempotency, concurrency conflict, pagination and authorization behavior.
Reject or ignore immutable/system-owned inputs safely; never trust created_by, tenant ownership, approval status or calculated totals from a client.
Validate at the boundary and within domain commands. Scope filtering and totals must not leak hidden items.
Endpoints for upload initiation/finalization/download authorization are separate from storing signed URLs as business records.
No promise of instantaneous real-time cross-device push synchronization is implied; refetch the shared server state appropriately.

## A-08 — OTP and session security
Use a provider interface, server-created challenges, expiry, bounded retries, resend throttling, one-use consumption,
phone normalization, abuse controls and non-enumerating responses.
Local development may use an explicit test-only OTP adapter and seed identities. It must fail closed in production configuration.
Do not return or log real OTPs/tokens. No universal production code, arbitrary-phone bypass or unauthenticated bootstrap-owner endpoint.
Separate new-owner onboarding from invitation acceptance to avoid accidentally creating workspaces for invited staff.
Document mobile secure-token storage, web session/cookie behavior, CSRF/CORS, refresh/revocation and logout before implementing auth.
Do not copy a 24-hour token requirement from an unrelated employer/project; it is not a requirement here.
Avoid storing long-lived browser credentials in localStorage as an unexamined default. Design and verify the chosen approach.
Production OTP provider choice and account recovery/phone-change verification are release gates, not blockers to isolated local testing.

## A-09 — Attachments and object storage
Store bytes outside the relational database. Keep attachment ID, workspace, uploader, original name, verified media type,
size, checksum where relevant, stable object key, processing state and authorized links in PostgreSQL.
Do not store durable access by saving a public URL or an expiring presigned URL in place of the object key.
Private buckets/objects; no cloud credentials or permanent bucket keys in Flutter/web.
Authorize initiation, completion and each download. A storage path is organization, not an access-control boundary.
Allow an explicit, documented image/PDF allowlist, count/size limit and image dimension checks. Reject disguised executable/HTML content.
Treat client MIME/filename as untrusted. Validate actual content, quarantine, scan and then mark ready for viewing.
Do not claim malware scanning is performed without a working scanner. An isolated dev-only bypass must be marked and blocked from production.
Presigned upload URLs, if used, target unique temporary objects and are short-lived. Finalization is idempotent and validates uploaded bytes.
The final authorized file should be an immutable/version-pinned checked object, not a still-writable upload target.
Short-lived download links are bearer capabilities: avoid logging/sharing, set sensible expiry, and serve safe preview/download headers.
Handle unsupported phone formats explicitly; no success message for a file the client/server could not read.
DB transactions do not make an object upload atomic with a money save. Model pending/failed/ready states and safe retry/cleanup.
An upload failure never duplicates or erases a saved entry. An abandoned temporary object is cleaned by a scoped policy.
Shared files require full original-document authorization, not merely authorization to one visible allocation.
Use an ObjectStorageService boundary. Production provider and region require approval; avoid silently purchasing or provisioning one.
For local work prefer a maintained approved S3-compatible test service. Verify its support/license/security before installing.
Do not choose an obsolete storage image based on previous chat claims. A dev filesystem adapter is allowed only if clearly labeled
and if real object-store integration remains explicitly NOT TESTED until exercised; no production fallback to app disk.

## A-10 — Notifications
Durable notification/outbox and scheduled-reminder state in PostgreSQL; worker processing with deduplication and bounded retry.
A process restart must not lose due reminders. Multiple worker instances must not produce repeated reminders for the same slot.
Renewal/archive cancels or invalidates future obsolete document reminders; financial outstanding obligations remain independent.
Re-check current membership/scope and current document state before send. Minimize sensitive push-lockscreen content.
Track read vs resolved separately; viewing a notification does not resolve the underlying issue.
FCM is a proposed transport, not proof of configured Android/iOS/web delivery. Use a dev sink until credentials/permissions are configured.
In-app notifications are the baseline regardless of push permissions. No WhatsApp/operational SMS integration in V1.
Missing historical thresholds on newly entered/expired documents must not trigger a burst of 30/7/1-day messages; document a dedup policy.

## A-11 — Operational safeguards and testing
Local/dev/test/prod configurations and datasets separated. No production credentials in Git, source screenshots or logs.
Migrations versioned; no automatic destructive schema recreation outside explicitly disposable tests.
Tests: backend units + PostgreSQL integration + API security + frontend unit/widget + full available-platform integration.
Testcontainers/Docker usage is conditional on actual available tooling and user authorization, not a claimed installed capability.
Test exact finance results, bad paths, cross-tenant reads/writes, shared attachments, idempotency, races and archive settlement.
Screenshot working Arabic mobile-width and desktop flows and distinguish these from native-device tests.
Actual iOS build/signing/device validation needs the user's appropriate platform tooling/account; report it as untested when absent.
Persist uploaded files outside container ephemeral storage. Back up PostgreSQL and object storage with a coordinated restore procedure.
Choose RPO/RTO/retention/provider region before live users and test restoration on isolated data.
Monitoring/logging must avoid leaking OTPs, tokens, signed URLs, full invoice bytes and unnecessary personal data.
A green pipeline is evidence of executed checks, not a blanket security/compliance certification.
