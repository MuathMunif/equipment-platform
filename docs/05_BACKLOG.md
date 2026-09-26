# Delivery backlog
Status 2026-09-26: M0–M6 are merged in `main` for local V1 development. M7 dashboard, three practical reports and product integration are implemented and locally tested on `feat/m7-dashboard-reports-polish`; PR #7 is open, with CI and populated Web visual QA pending. See `docs/tasks/007_M7_STATUS.md` and `HANDOFF.md`. Private production object storage, malware scanning, live Push and production OTP remain deferred. This is not production readiness.

Localization foundation before M4 is merged into main: `ar`, `en`, `ur` resources, user-level saved preference, localized app UI and semantic notification templates. Arabic remains fallback. Urdu copy requires native-speaker review before public release.

M2 also implements the D-08 general/shared expense model with V6 allocation backfill, explicit amounts, active workspace/equipment totals, and deterministic proportional shares. D-20 locks all entry totals after movement but permits audited expense allocation/classification corrections at unchanged total.

The attachment-only quick draft is implemented locally in V7: required equipment, optional note/attachments, excluded from totals, in-place completion preserving attachment identity, and discard.

Financial history search/filter is implemented locally with bounded 30-row pagination and workspace isolation.

Development-only attachment lifecycle cleanup is implemented in V8 for stale PENDING/FAILED, discarded-draft attachments and local orphan files with configurable retention. Production private storage/scanning remains unselected and unverified.

Focused M2 financial hardening is implemented in V9 and API/UI: refunds that reopen an unnamed obligation require and persist the party name, edit after refund keeps party safety, and SQL enforces posted entry type. D-20 supersedes the historical-gross edit limit: any financial movement locks the original total, while audited expense classification corrections remain allowed.

Connected iOS simulator acceptance now covers M2 journeys A–J using live local API/PostgreSQL; some steps are API-driven within the Flutter integration test. Web release build and short responsive live smoke pass; automated Flutter integration on Chrome is unavailable with the installed toolchain. Android remains unverified.
M2 is FUNCTIONALLY COMPLETE for V1 development after D-20 and tests; Production Readiness remains separate.
Break each milestone into small independently reviewable tasks; this list is not a request for one giant code generation.
The first session should reach M1 where tooling permits, not stop after documentation.

## M0 — Inventory and foundation
Inspect the chosen folder and Git state; preserve existing work. Verify SDK/runtime availability and document versions.
Validate handoff consistency, choose bounded implementation defaults, establish runnable backend/app skeletons,
PostgreSQL migrations, test commands and development configuration. Establish tenant-aware design immediately.
Create a working branch if appropriate; do not create/push a remote without approval.
Deliver: `ENVIRONMENT`, startup commands actually tried, task decomposition, initial API/auth contract and checks.
Gate: coherent repository that builds/tests in the reported environment; tooling absences explicitly recorded.

## M1 — First real vertical slice (initial delivery)
Subtasks: identity/OTP dev adapter + secure session baseline; implicit workspace creation; equipment create/list/detail;
fully paid expense entry; persistence; attachment state and one working upload/download dev path; Arabic responsive UI.
Use real PostgreSQL persistence for the tested slice. No hard-coded list advertised as backend integration.
A user can refresh/restart supported services and retrieve the equipment, entry and authorized attachment.
Only name/model required for equipment. No accountant/company/project/driver dependency.
Reject cross-workspace equipment and attachment access. Demonstrate a duplicate save returns one entry.
Deliver screenshots of actual mobile-width and desktop flows, test evidence, startup/seed/reset instructions and known limits.
If local object storage is temporarily substituted, label the substitution and leave S3 integration incomplete, not passed.
Gate: user-facing working flow with honest distinction between live server behavior and external providers not configured.
See `tasks/001_FIRST_VERTICAL_SLICE.md` and acceptance AUTH/EQ/FIN/FILE/TEN cases.

## M2 — Core entry UX and reliable attachments
Income, partial/unpaid creation, counterparty when outstanding, settlements with dates,
entry detail/history, allowed edits, search/filter, draft photo capture/completion,
validated/quarantined attachments and retry handling, protected private object access.
Complete real selected object-store integration tests if M1 used an explicit fallback.
Gate: exact balances, nonduplicating files/payments, reliable retrieval, failure paths demonstrated.

## M3 — Equipment documents and alerts (owner's 2026-09-25 scope)
Equipment-only document/version history, optional expiry, renewal, archive/restore and version-specific attachments.
Backend-derived status with Asia/Riyadh dates; attention and incomplete-data views; persistent owner notifications,
30/7/1/today reminders and Sunday expired aggregate with restart-safe deduplication. Flutter mobile/web flows and
connected acceptance evidence are required before marking M3 functionally complete. Live Push remains pre-Beta.
General/shared expenses were completed in M2. Period financial reporting remains future scope, not silently part of M3.

## M4 — Issues and maintenance (owner's 2026-09-25 scope)
Merged into `main`: optional issue type/stopped flag; OPEN → IN_PROGRESS/CLOSED and reopening; resolution history; independent completed-work maintenance records with optional issue link; cancellation without deleting financial entries; protected attachments; multiple eligible M2 expenses per maintenance record; derived financial summary; global/equipment lists and issue Attention; ar/en/ur UI. Flyway V13 and acceptance evidence are recorded in `HANDOFF.md`.
Gate: three owner journeys (linked repair, direct maintenance, simple issue), workspace isolation, and no duplicated financial value. Work orders, preventive schedules, readings, issue priorities and independently stored maintenance costs are outside M4.

## M5 — Team, drivers and permissions (owner's 2026-09-25 scope)
Merged into `main`: seven-day invitations and acceptance/decline, owner/manager/accountant/driver presets, capability overrides, equipment scope, direct/review financial modes, revocation, workspace switching, single active driver assignment with history, expense-only driver submissions and review, semantic notifications, and ar/en/ur UI. Rejected submissions can create a new linked request without rewriting review history; approved submissions leave later money changes to M2. Flyway V14–V17 and negative authorization tests cover existing M0–M4 routes. Gate: local tests and connected acceptance, then PR/CI review; production identity and storage are still deferred.

## M6 — Optional organizations, projects and contracts (owner's explicit scope)
Merged into `main` by PR #6 at `11afef6`. Organizations group equipment and project records inside the workspace and are never required for existing workflows. Equipment has zero or one current organization with assignment history. PROJECT and CONTRACT are one typed module with optional organization, ACTIVE/COMPLETED plus archive, multiple historical equipment links, private attachments and optional M2 classification. Financial summaries derive from M2 only. M5 non-driver access adds live SELECTED_ORGANIZATIONS and protects M0–M5 resources on each request. Flyway V18–V21 and ar/en/ur UI are included. Local suites, fresh and upgraded databases, connected API journeys, representative web smoke, and independent UX/security reviews passed before merge; see HANDOFF. Production providers remain separate.

## M7 — Dashboard, three practical reports and product integration, local implementation complete
Approved scope: a permission-aware home, recorded-entry report by transaction date, payments/collections report by movement date, and current outstanding across all periods; navigation and drill-downs must match those bases. Preserve M0–M6 money, access and workflows. See `docs/tasks/007_M7_STATUS.md` for branch and gate state. Production providers, account recovery/deletion, monitoring, backup/restore, native-device and staging readiness remain separate release work; M7 does not complete them. Pricing/commercial scope and publishing require separate decisions.

## Suggested task format
Task ID + source requirements + dependencies + affected folders + acceptance IDs + out-of-scope + evidence + status.
Use `TASK_TEMPLATE.md`. Keep one writer before M1 passes. Later parallelize only independent work with a stable API contract.
Do not mark later phases done because placeholders or future entity classes exist.
