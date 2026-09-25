# Delivery backlog
Status 2026-09-25: M0/M1, M2, and the owner's latest M3 scope (equipment documents, attention, in-app notifications) are functionally complete for local V1 development on `feat/m3-documents-alerts`, as evidenced in `HANDOFF.md`. Private production object storage, malware scanning and live Push remain deferred. This is not production readiness. M4 and later work have not started under this task.

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

## M4 — Corrections, refunds and archive lifecycle
Q-01 is resolved by D-19 and Q-02 by D-20; linked refunds and audited classification corrections are implemented in M2.
Complete any additional correction/refund policy paths, equipment archive and old balance settlement.
Gate: history preserved, business meaning explicit, no silent retrospective rewrite or erased obligation.

## M5 — Issues and maintenance (future scope)
Issues and simple statuses, one financial expense linked to maintenance, and the remaining maintenance rules.
Equipment documents and owner document notifications moved to the approved M3 scope. No M5 implementation has started.

## M6 — Optional team and multi-workspace experience
Invitations and acceptance, owner/manager/accountant/driver role presets, resource scope and customization,
submission/review with Q-03/Q-12 resolved, honest entered-by/source distinction,
driver assignment history, membership revocation, tenant switching and team-aware notification recipients.
Gate: all tenant and permission-negative tests pass, including shared originals and hidden totals; owner still works alone.

## M7 — Optional organization/project features and launch blockers
Basic organizations/associations; project/contract details after Q-04/Q-05 approval.
Choose live providers/region, implement account/phone/recovery/deletion policies, push platform integrations,
production configuration, monitoring, backup/restore drill, native device tests, staging and owner UAT.
Pricing/commercial scope and publishing are separate explicit owner decisions.
Gate: release checklist complete; do not call V1 production-ready merely because web builds.

## Suggested task format
Task ID + source requirements + dependencies + affected folders + acceptance IDs + out-of-scope + evidence + status.
Use `TASK_TEMPLATE.md`. Keep one writer before M1 passes. Later parallelize only independent work with a stable API contract.
Do not mark later phases done because placeholders or future entity classes exist.
