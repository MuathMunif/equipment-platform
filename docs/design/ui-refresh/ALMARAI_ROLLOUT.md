# Full A + F3 Almarai rollout

## Source and authority
Owner instruction: [ALMARAI_ROLLOUT_TASK.md](ALMARAI_ROLLOUT_TASK.md). Branch `feat/ui-a-almarai-rollout`, source `6f61d3bf965453e0c6f402efc9b86fe3db65ce46`. Inherits unmerged design-directions, EquipmentDetail pilot and typography work; origin/main `8aae24fddf37ec39d5a93b475e4a65a82d406923` is an ancestor. Date fix included. No backend/API/migration/math changes authorized.

## Ordered queue
| Batch | Scope | Status / checks / commit |
|---|---|---|
| 1 | Expense/edit proving ground; A root/overlays; login, workspace, home/dashboard, equipment list/form/detail, More/settings | IMPLEMENTED / affected83 PASS; later focused11 and24 PASS (overlap); analyze + actual web PASS; commit `30ff1c0` |
| 2 | Ledger, entry detail, settlements/refunds/cancellation, allocations, drafts/attachments, reports/drill-down | IMPLEMENTED;53 affected +16 focused PASS (overlap); analyze/web PASS; journeyA complete; independent behavior review found no actionable regression |
| 3 | Documents/version/renewal/archive, attention/incomplete/notifications | IMPLEMENTED;54 focused PASS, analyze/web PASS; connected renewal/old-file journeyC complete |
| 4 | Issue/maintenance/detail/history/status/attachments and original M2 links | Pending |
| 5 | Team/invitations/permissions/scope/DIRECT–REVIEW/assignment, driver, review flow | Pending |
| 6 | Optional organizations and projects/contracts, linking/history/attachments/summary | Pending |
| Final | Full Flutter once, analyze, 3 web builds, feasible native builds/runs, connected journeys, final visual review, branch PR+CI | Pending |

Last implemented/tested batch: 3. Next action: batch4 issues/maintenance. Remaining locale/final-pixel captures are tracked in the screenshot index. JourneyA complete on existing record. Continue through queue without routine approval.

## Evidence discipline
[Coverage](COVERAGE.md) separates theme propagation, widget tests, connected actions and actual visual inspection. [Screenshots](ALMARAI_ROLLOUT_SCREENSHOTS.md) contains only actual rendered images. Previous pilot182 tests are not rollout results. Batch1 actual screenshots and connected partial-expense save recorded below; full journeys pending.

## Resources
Main writer only; one bounded read-only behavior reviewer completed, requested Astra/High. At most one sequential read-only Astra/High behavior review after batch2 and one final visual review. No automatic role/model fallback. User-reported Astra/High; runtime not exposed. Project/global configuration unchanged.

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

## Batch2 — commit `1d6b36e`
- Existing journal reuses the proven A entry card. Draft list/detail recovery and completion separated into panels. Real financial detail has identity, amounts, settlement/history and attachments sections; cancellation action keeps confirmation and uses semantic error color. Reports use bounded filters and responsive metric grid. Month grid adapts at200%; date logic unchanged.
- Fixed pre-existing uncertain-save UI holes exposed while validating state: allocation amount fields and project picker now disable during busy/uncertain just like other inputs. Request key lifecycle/API/body/calculations unchanged. New test proves identical body+key on retry. Not a domain/permission change.
- Checks: `flutter analyze` clean; widget/reports/rollout **53 PASS**; focused rollout with actual Almarai/Plex fonts **16 PASS** including 3locale huge amounts/keyboard/refund,200%monthgrid and immutable ambiguous retry. Counts overlap. Web release PASS including latest amount alignment, attachment spacing and uncertain guards.
- Connected journeyA COMPLETE via actual UI: existing synthetic owner -> EQ-000037 -> one1000 expense -> initial600 -> one200refund, UI shows paid600/refunded200/net400/remaining600. Added existing `synthetic-receipt.png` once and opened it through protected app viewer. Fixture image says350 from older tests; it is a generic synthetic upload artifact, not the source of this entry's1000 total (no OCR/calculation from image). No auth bypass/OTP/new identity. Record note `A-F3 rollout — journey A` is unique and reusable.
- Opened real edit: total field disabled after movements; fields/category/equipment/date/party/note retained. Did not save an unnecessary edit. Actual financial screenshots saved, final alignment capture pending.
- One approval-review timeout affected Flutter check launch; authorized retry succeeded. No sandbox/global changes.
- Independent static review by `/root/rollout_behavior_review` (requested Astra/High, no edits/test execution) found no actionable regression in the assigned financial/forms diff. Reviewer checked exact amounts, total lock, classifications, DIRECT/REVIEW guards, retry identity, stable fields/navigation/date/filter code; did not claim device/screen-reader/visual coverage. Native/full suites/CI still pending final batch.

- Connected reports: recorded2850 expenses/4500 income; movements paid2450/refunded200/net2250; current remaining600 under expense filter. Entry drill-down/back retained October1–31, EXPENSE and date basis. Project drill-down deferred batch6 fixture.

## Batch3
- Documents, history, attention, incomplete and notifications use bounded A page composition and spaced cards. Create/edit/renew form shares mounted form section; dropdown wraps; current status badge and distinct attachment panel. Previous immutable info panel, incomplete action wraps under content and pagination wraps. Native file picker unchanged.
- Dates, version id/concurrency, upload recovery, archive guards and notification semantics unchanged. One formatting-only missing-brace lint fixed; one test tap helper now waits for focus/scroll settling after text entry. First run53pass/1failed offscreen tap; corrected **54/54 PASS** (documents+pilot+rollout including3language real-font320/200% renewal and keyboard checks), analyze clean, productionweb PASS.
- JourneyC via actual production English UI on existingEQ37 insurance: attach synthetic receipt toversion1, renew ONCE to2027-10-15 note`A-F3 rollout — renewal C`, verifycurrent date andversion1expiry2026-10-15 readonly, openversion1protectedfile. Currentversionhasnoattachments, provingversionseparation. No duplicate document/new account.
- Actual English mobile form/detail/oldversion/viewer images inspected. Arabic/Urdu final representative captures still pending.
