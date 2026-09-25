# Acceptance and regression test catalog
Status: broader acceptance catalog; a tested local M2 subset is documented below.

## M4 local acceptance — 2026-09-25

- ISSUE-01: A description-only issue saves with a unique generated reference, optional type and default `equipmentStopped=false`; a stopped OPEN issue appears first in Attention, while IN_PROGRESS/CLOSED issues do not.
- ISSUE-02: OPEN may start or close directly; closing requires a resolution, preserves actor/time/history, and reopening returns to OPEN without erasing the prior closure. CLOSED is otherwise read-only.
- MAINT-01: Completed-work maintenance saves directly from equipment or from an issue on the same equipment; another equipment's issue is rejected. Cancellation requires a reason, keeps history and leaves linked expenses untouched.
- MAINT-02: Multiple eligible M2 EXPENSE entries can link to one maintenance record, but each expense has at most one maintenance link. INCOME, general/shared, another equipment/workspace and duplicate links are rejected. Unlinking changes only the association.
- MAINT-03: Total, net paid and remaining are derived from active linked M2 entries; later settlement/refund changes the display, while cancelled expenses are excluded from active totals.
- MAINT-04: Issue images and maintenance images/PDF are protected by workspace authorization and normal attachment validation. Archived equipment keeps history but rejects new operational records and removes issue Attention until restored.
- UI-04: AR/EN/UR use RTL/LTR appropriately; forms omit title, priority, meter and independent cost fields. Web and mobile present issue/maintenance lists, state-specific actions, error/loading/empty states, and finance links.

Backend HTTP/PostgreSQL regression and Flutter widget tests cover selected paths. A connected web journey covered issue → IN_PROGRESS → maintenance → linked M2 expense → close; other connected journeys and native-device M4 checks must be recorded separately if run. Passing a build does not prove every journey.

# تنفيذ قبول M2 المحلي بتاريخ 2026-09-24: اختبارات Backend HTTP/PostgreSQL ‏43/43، Flutter unit/widget ‏29/29، وiOS simulator integration ‏2/2 تغطي رحلات A–J المذكورة في HANDOFF؛ بعضها عبر API حي داخل اختبار Flutter. Web release وفحص سجل/مرشحات حي بعرضين نجحا. Web E2E آلي وAndroid والإنتاج غير متحققين. حالات القبول التالية تبقى مواصفات للمنتج الأشمل؛ وجود اختبار مرتبط لا يعني اكتمال كل المسارات الإنتاجية.
Automate progressively and map each ID to actual test names/evidence. Passing mocks is not proof of live integrations.

## Authentication and onboarding
AUTH-01: New owner verifies a phone and name; exactly one default workspace is created on a retried onboarding request.
AUTH-02: Invited phone joins the existing permitted workspace; no unwanted new owner workspace is created.
AUTH-03: Expired, reused or wrong OTP is rejected; attempts/resends are bounded and do not disclose account existence.
AUTH-04: A dev OTP adapter cannot be enabled under production settings; production starts fail-closed when misconfigured.
AUTH-05: Session expiry, logout and revoked membership prevent protected calls and downloads.
AUTH-06: Switching workspace does not reuse the previous workspace's list cache, counts, entry form target or notification data.

## Equipment
EQ-01: Name + model create equipment; no organization, plate, driver, project, image or document is required.
EQ-02: Internal reference exists and is unambiguous within the workspace; authorized retries do not create duplicates.
EQ-03: A model designation that is not a year is not rejected by an invented year-only requirement.
EQ-04: Equipment details preselect the same equipment for a new expense/income; no second compulsory equipment selection.
EQ-05: An action requiring a missing official field asks there only; unrelated equipment actions remain available.
EQ-06: Archive removes from active operation choices, preserves historical summaries and permits settling an existing balance.
EQ-07: Driver reassignment retains earlier assignments and does not imply changing the user's entire role.

## Money, dates and lifecycle
FIN-01: Income total 3000.00, initial receipt 1000.00 => remaining 2000.00; subsequent receipt 2000.00 => remaining 0.00;
        total original income is still 3000.00, not 5000.00 or 6000.00.
FIN-02: Expense total 350.00 paid in full creates one entry + its settlement, not two expenses.
FIN-03: Unpaid entry requires a party name, not a separately created customer/supplier object; due date is optional.
FIN-04: No due date does not produce an overdue label by assumption.
FIN-05: Invalid/negative/excess settlement is rejected. Two concurrent final-balance payments cannot overpay.
FIN-06: A replayed idempotency key with the same authorized payload returns the original result; a different payload conflicts.
FIN-07: Before any settlement/refund, total may be edited with normal validation. After the first financial movement, original total cannot change at all for expense or income.
FIN-08: Settlement status is derived; submitting paid=true without valid settlements cannot mark a debt paid.
FIN-09: General expense 200.00 + equipment A expense 350.00 => workspace 550.00, equipment A 350.00, general 200.00.
FIN-10: Shared expense total 1200.00 with A=700.00/B=500.00 counted once at workspace level. A sees its authorized share only.
FIN-11: Paying 600.00 on FIN-10 yields computed paid shares A=350.00/B=250.00; remaining shares A=350.00/B=250.00.
FIN-12: Missing/mismatched allocation sum is rejected; equal split is never applied without explicit choice.
FIN-13: Tiny-cent equal/non-equal allocations over many settlements reconcile every total deterministically; full settlement
        exhausts each original allocated amount exactly. No accumulated rounding creates a phantom balance.
FIN-14: Operation 2026-09-01 entered 2026-09-24 and paid 2026-09-20 stays in the correct operation/cash/audit dates.
FIN-15: Operation in September settled in October appears in September operation totals and October cash; same money is not doubled.
FIN-16: Draft, incomplete image-only submission, pending-review and error-cancelled records do not enter recognized totals.
FIN-17: Original real expense or income with actual returned money retains settlement and refund history; each cash return has its own date.
        Per D-19, net settled = original settlements - refunds; remaining = original total - net settled.
        Expense 1000.00 / paid 600.00 / refunded 200.00 => net paid 400.00 / remaining payable 600.00.
FIN-18: Active expense allocation/classification may be corrected after movement at unchanged total, including single/shared/general conversions; exact sum, same-workspace equipment and before/after audit are required. Historical settlement/refund rows remain unchanged; calculated equipment shares reflect the current classification.
FIN-19: Financial record mistaken/duplicate cancellation keeps actor/time/reason and excludes erroneous totals; actual refund is not simulated by it.
FIN-20: Editing a note or adding an attachment creates no payment, changes no original amount and preserves audit evidence.
FIN-21: Current outstanding differs from period cash; labels never claim net profit, bank balance or zero activity from missing entries.

## Attachments
FILE-01: A stored entry gains an image/PDF attachment without another expense entry.
FILE-02: Save succeeded, file upload failed => entry remains once, state explains failure, file-only retry succeeds.
FILE-03: Image-only draft can be completed into the same logical entry; it is not counted beforehand and not duplicated afterwards.
FILE-04: No public bucket, permanent client secret or saved presigned URL used as durable business storage reference.
FILE-05: Unauthorized entry/file/original shared invoice access is denied, including filenames, previews and download-link creation.
FILE-06: Fake MIME, prohibited type, oversize and corrupt payload do not become ready attachments.
FILE-07: A file cannot be replaced after validation by replaying an unexpired temporary upload URL against the finalized file.
FILE-08: Upload finalization is idempotent; abandoned temporary uploads can be cleaned without deleting live attachments.
FILE-09: Scanner unavailable does not label content scanned. Production does not silently use a dev validation bypass.
FILE-10: Supported phone image/PDF input is tested; unsupported formats give a useful error instead of pretend success.
FILE-11: Object storage survives supported restart and a restore drill retrieves bytes, not just metadata references.

## Authorization, tenants and teams
M5 final gate (2026-09-25): `TeamM5Test` includes rejected-request resubmission and immutable approved-history checks alongside invitation lifecycle, owner protection, driver uniqueness/history/concurrency, REVIEW bypass attempts through legacy M2 routes, double approval, revocation, selected-scope resource/file/totals denial, and workspace switching. A connected API/PostgreSQL journey verified driver submission through approval, access scope, live permission change, driver move and revocation. iOS/Android M5 remain unverified; UI smoke is recorded in HANDOFF.
TEN-01: User in workspace A cannot read/update/delete/archive/list/search B's equipment by guessing an ID.
TEN-02: Cross-workspace references to equipment/entries/attachments/organizations are rejected.
TEN-03: Restricted equipment scope does not expose other equipment through totals, counts, selectors, exports or notifications.
TEN-04: A shared original containing unauthorized equipment cannot be retrieved from a visible allocation.
TEN-05: Access to one equipment does not grant general-account expenses or workspace-wide financial reports.
TEN-06: Membership/assignment removal affects subsequent authorized actions, including old deep links and file-link issuance.
TEN-07: Idempotency/cached responses recheck current access and cannot replay another tenant's result.
TEAM-01: Owner can add/edit ordinary work without any accountant or second approver.
TEAM-02: Driver financial submission goes pending and is excluded; an authorized reviewer posts it once.
TEAM-03: Driver issue reaches the responsible user immediately regardless of financial review.
TEAM-04: Accountant entering on driver's behalf remains created_by; optional source identifies the driver without impersonation.
TEAM-05: Role fields cannot be mass-assigned by a driver/request payload; driver cannot grant self financial approvals.
TEAM-06: Invitation reuse, wrong phone, revocation, expired invitation and duplicate acceptance follow tested safe behavior.
TEAM-07: Shared-history access after organization changes follows explicit Q-04, not a silent foreign-key update.
TEAM-08: Editing previously approved driver-origin money cannot bypass the Q-03 review policy.

## Documents/issues/notifications
M3 local checkpoint (2026-09-25): equipment document/version/attachment, status, renewal conflict, archive, attention, notification dedupe and tenant checks are covered by the 50-test backend suite. Flutter has 40 unit/widget tests in total, including M3 mobile/web RTL, forms, renewal/history, archive, attention, notifications and upload retry. A connected M3 iPhone simulator journey passed 1/1 with local API/PostgreSQL. Web E2E, Android, live Push and production storage/scanning remain unverified. ISSUE and maintenance cases below are future scope.
Localization foundation checkpoint: backend suite 52/52 verifies user preference scope/persistence and old/new notification formats; Flutter 52/52 covers `ar`/`en`/`ur`, RTL/LTR, runtime switch, statuses, error codes and semantic notification rendering. Chrome localization widgets 10/10 and connected M3 iPhone 1/1 pass. Urdu linguistic approval and live web E2E remain unverified.
DOC-01: Equipment without a document is not shown as document-compliant; missing data doesn't block expenses.
DOC-02: Adding expiry reminders requires a valid expiration date; no invented expiration from model year.
DOC-03: Renewal preserves old version, makes new current and prevents old future notifications.
ISSUE-01: Issue may close without a cost; periodic maintenance expense may exist without an issue.
ISSUE-02: Linked expense appears under issue and finance but amount is counted only once.
ISSUE-03: Closing an issue doesn't settle its invoice or automatically mark vehicle operational.
NOTIF-01: Scheduled document reminders match configured 30/7/1/expiry thresholds and weekly overdue digest.
NOTIF-02: Read state differs from resolved state; reading does not suppress the unresolved status incorrectly.
NOTIF-03: Restart/retry/concurrent worker cannot duplicate the same recipient/reminder slot.
NOTIF-04: Renew/archive/revoke between scheduling and send prevents obsolete or unauthorized notification.
NOTIF-05: Newly added expired document doesn't trigger a burst of historical reminder thresholds.
NOTIF-06: Owner doesn't receive a redundant notification for their own newly saved expense.
NOTIF-07: Financial due reminders don't send messages to external parties and survive equipment archive where relevant.
NOTIF-08: Push denied/unavailable still leaves an authorized in-app notification.

## UX and environment
UX-01: Arabic RTL is usable at mobile width and desktop; mixed numbers/dates, clipping, keyboard focus and labels checked.
UX-02: An empty account shows an add-equipment action, not fake successful business metrics.
UX-03: Saved operation can be found after refresh/restart from equipment and global filtered ledger.
UX-04: During timeout/double tap, user sees accurate save state and does not accidentally submit another transaction.
UX-05: No GPS/maps/coming-soon GPS, mandatory organization onboarding, or duplicate invoice module.
UX-06: Same authorized financial flow is possible on mobile and web; layout differences do not remove key functionality.
OPS-01: Document exact tools/commands/check exit results and NOT RUN platforms. Native iOS proof is not a resized browser screenshot.
OPS-02: Test data/configuration is distinct from live users; secrets and temporary signed links are absent from repository/logs.
OPS-03: Migrations run on fresh DB and upgrade prior test schema without destructive recreation outside disposable tests.
OPS-04: Restore exercise covers DB and object bytes; actual outcome/evidence documented before real users.
OPS-05: Account deletion never accidentally cascades other members' shared records; approved retention/ownership policy is tested.

## Evidence record per task
Record: ID, commit/diff, environment, command or manual steps, expected result, actual result,
status (PASS/FAIL/NOT RUN), evidence path, defect links and reviewer identity/session if available.
No fabricated pass counts, screenshots, CI links or deployed URLs.
