# Full A + F3 Almarai rollout

## Source and authority
Owner instruction: [ALMARAI_ROLLOUT_TASK.md](ALMARAI_ROLLOUT_TASK.md). Branch `feat/ui-a-almarai-rollout`, source `6f61d3bf965453e0c6f402efc9b86fe3db65ce46`. Inherits unmerged design-directions, EquipmentDetail pilot and typography work; origin/main `8aae24fddf37ec39d5a93b475e4a65a82d406923` is an ancestor. Date fix included. No backend/API/migration/math changes authorized.

## Ordered queue
| Batch | Scope | Status / checks / commit |
|---|---|---|
| 1 | Expense/edit proving ground; A root/overlays; login, workspace, home/dashboard, equipment list/form/detail, More/settings | IMPLEMENTED / affected83 PASS; later focused11 and24 PASS (overlap); analyze + actual web PASS; batch1 commit carries this record |
| 2 | Ledger, entry detail, settlements/refunds/cancellation, allocations, drafts/attachments, reports/drill-down | Pending; focused independent behavior review only after implementation |
| 3 | Documents/version/renewal/archive, attention/incomplete/notifications | Pending |
| 4 | Issue/maintenance/detail/history/status/attachments and original M2 links | Pending |
| 5 | Team/invitations/permissions/scope/DIRECT–REVIEW/assignment, driver, review flow | Pending |
| 6 | Optional organizations and projects/contracts, linking/history/attachments/summary | Pending |
| Final | Full Flutter once, analyze, 3 web builds, feasible native builds/runs, connected journeys, final visual review, branch PR+CI | Pending |

Last implemented/tested batch: 1. Next action: commit batch1, migrate finance/detail/reports/drafts/attachments (batch2), complete refund200 on existing journeyA record and perform the bounded behavior/accessibility review. Continue through queue without routine approval.

## Evidence discipline
[Coverage](COVERAGE.md) separates theme propagation, widget tests, connected actions and actual visual inspection. [Screenshots](ALMARAI_ROLLOUT_SCREENSHOTS.md) contains only actual rendered images. Previous pilot182 tests are not rollout results. Batch1 actual screenshots and connected partial-expense save recorded below; full journeys pending.

## Resources
Main writer only; no rollout subagents yet. At most one sequential read-only Astra/High behavior review after batch2 and one final visual review. No automatic role/model fallback. User-reported Astra/High; runtime not exposed. Project/global configuration unchanged.

## Batch1 implementation and evidence (completed implementation; final family/locale capture gaps remain explicit)
- Root now uses existing EquipmentA/EquipmentTypography. Explicit dialog/date/dropdown/snackbar/navigation typography, true400/700 and Plex fallback. Historical referenceTheme/gallery preserved.
- Reusable bounded page canvas, section panels, adaptive field/overview rows; all form validators stay mounted. Expense has context, details, payment and optional details sections, desktop columns/mobile stack. Edit retains total-lock and distribution controls. Long dropdowns expand/wrap.
- Core login/equipment forms use A panels; equipment/search/settings/More bounded layouts; home uses current attention beside month financial summary on wide screens. Same routes and permission predicates.
- Navigation presentation wraps labels without Material's text-scale cap; same owner/driver destinations and callbacks. Keyed content/home sections preserve state and avoid new reads at width changes. No API, write lifecycle or calculations changed.
- Actual runs: initial focused60 pass/2 failures (duplicate section/field wording; save tap after scroll). Follow-up67 pass/5 failures exposed test scroll timing and unkeyed conditional home children; fixed. Main affected suites **83/83 PASS** (widget, pilot, reports, team, rollout). Additional new keyboard check included in **11/11 PASS** rollout suite. Final affected layout suite **24/24 PASS** including latest home composition. Counts overlap, not summed. Analyze clean; real web release build passed. No full Flutter/backend/native campaign yet.
- Test expectation updates: pilot routes now expect approved ROOT typography; driver navigation tests expect the wrapping presentation widget. Existing financial/access assertions retained. Scroll test now waits for settled viewport before tapping Save; no production bypass.
- Connected existing synthetic owner/workspace/EQ-000037: created exactly ONE expense `A-F3 rollout — journey A`, amount1000, initial payment600, remaining400, party `مورد التحقق UI-A`; normal production UI/API. Refund200 deferred to batch2 on THIS record. No OTP, data reset or new account.
- Actual screenshots in rollout index. First desktop view showed overly wide home attention; fixed with stable responsive columns beside dashboard. Expense columns top-aligned after visual self-review. No independent review yet (reserved afterbatch2).
- Runtime: local web8081 now serves `.local/almarai-rollout/web-production` (Python session72674). Old pilot build preserved; API/Docker untouched.

Final batch1 visual pass:9 actual connected images saved and inspected. Added More/settings panels after real render. Language modal minWidth280 restored after narrow intrinsic-width render; final recapture with next production build. Last analyze clean, web release PASS, whitespace PASS. No rollback of business/security assertions. No backend changes or new binaries/dependencies.
