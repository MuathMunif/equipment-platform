# Actual rollout screenshots

All below are actual production `lib/main.dart`, connected local API/session, synthetic OWNER `مالك اختبار iOS`, ar, height1000. No preview/harness images in this batch. Source: batch1 working changes on approved `6f61d3b`; carried by the batch1 commit. Images actually opened and self-inspected. Later final visual review must distinguish representative coverage from every-state verification.

| Screen | Viewport | Image | Notes |
|---|---|---|---|
| Home/dashboard |390|[home](screenshots/almarai-rollout/home-ar-390.jpg)|Current attention, recorded totals2850/4500 after one test expense|
| Home/dashboard |1440|[home wide](screenshots/almarai-rollout/home-ar-1440.jpg)|Final proportional columns, normal sidebar|
| Equipment list |390|[equipment](screenshots/almarai-rollout/equipment-list-ar-390.jpg)|Existing2 synthetic equipment, search/add preserved|
| Actual partial-expense form |390|[partial expense](screenshots/almarai-rollout/expense-partial-ar-390.jpg)|1000/600/party before successful save; viewport scrolled, not clipped page|
| Actual expense form |1440|[expense wide](screenshots/almarai-rollout/expense-ar-1440.jpg)|Final top-aligned panels; input1000 only, discarded via confirmation; no second save|
| Unsaved warning |1440|[unsaved](screenshots/almarai-rollout/unsaved-dialog-ar-1440.jpg)|Actual app modal and safe exit|
| More |390|[more](screenshots/almarai-rollout/more-ar-390.jpg)|Existing owner destinations|
| Account/settings |390|[settings](screenshots/almarai-rollout/settings-ar-390.jpg)|Existing user and language control|
| Language dialog |390|[language](screenshots/almarai-rollout/language-dialog-ar-390.jpg)|Recaptured batch5 final width280 on actualdriver dialog|

Later sections contain additional locales/families/native. Widget results remain distinct from connected screenshots.

## Batch2 — connected production / synthetic OWNER
Actual images captured and self-inspected: `refund-dialog-ar-390.jpg`, `entry-refunded-ar-390.jpg`, `entry-refunded-ar-1440.jpg`, `entry-history-attachment-ar-390.jpg`, `receipt-viewer-ar-390.jpg`, `report-recorded-ar-1440.jpg`, `report-movements-ar-1440.jpg`, `report-outstanding-ar-390.jpg` in `screenshots/almarai-rollout/`. AR detail390/1440 recaptured with batch6 final alignment. `entry-history-attachment-ar-390.jpg` is historical before attachment-margin correction; do not treat that image as final geometry. Reports show real current synthetic data; outstanding is all-time current600, not an October snapshot. Receipt image350 is an existing generic synthetic attachment, not a calculation input for entry1000.

## Batch3 source (after1d6b36e, current batch3 changes)
Connected OWNER/en/390×1000 actual self-inspected: [finance](screenshots/almarai-rollout/entry-refunded-en-390.jpg) latest valuealignment; [document](screenshots/almarai-rollout/document-en-390.jpg), [renewform](screenshots/almarai-rollout/document-renew-en-390.jpg), [oldreadonly](screenshots/almarai-rollout/document-history-en-390.jpg), [protectedoldfile](screenshots/almarai-rollout/document-old-attachment-en-390.jpg). Historicalattachmentname/frame are app-controlled Almarai; imagecontents are syntheticfixture.

## Batch4 source (after3c5590c, current batch4 changes)
Connected OWNER/en actual inspected: [openissue390](screenshots/almarai-rollout/issue-open-en-390.jpg), [linkedmaintenance1440](screenshots/almarai-rollout/maintenance-linked-en-1440.jpg), [closedissue390](screenshots/almarai-rollout/issue-closed-en-390.jpg). Height1000. Hover tint on relatedmaintenance row is pointerstate. No preview or duplicatedfinance.

## Batch5 source (afterfd5326a, current batch5 changes)
All connectedproduction/syntheticroles/height1000, self-inspected:
- DRIVER: [ar390](screenshots/almarai-rollout/driver-ar-390.jpg), [en390](screenshots/almarai-rollout/driver-en-390.jpg), [ur390](screenshots/almarai-rollout/driver-ur-390.jpg), [UR form390](screenshots/almarai-rollout/driver-submit-ur-390.jpg) (finalstableunsaved250sample, discarded), [pendingUR](screenshots/almarai-rollout/driver-pending-ur-390.jpg), [approvedUR](screenshots/almarai-rollout/driver-approved-ur-390.jpg).
- OWNER/reviewer: [requestEN390](screenshots/almarai-rollout/review-en-390.jpg), [approvalEN390](screenshots/almarai-rollout/approval-en-390.jpg), [teamEN1440](screenshots/almarai-rollout/team-en-1440.jpg), [teamUR390](screenshots/almarai-rollout/team-ur-390.jpg). Both team images recaptured during final closeout with revoked label and isolated LTR phone.
- SameuserworkspaceF: [selectorUR390](screenshots/almarai-rollout/workspace-picker-ur-390.jpg), [ownemptyUR390](screenshots/almarai-rollout/workspace-own-empty-ur-390.jpg). Actualemptyconnected, notharness.


## Batch6 / final production source (after6345219 plus batch6 changes)
All connected synthetic OWNER0802; height1000 unless native. Saved and self-inspected:
| Screen | Locale / viewport | File | Evidence |
|---|---|---|---|
| Optional project form | ar/390 | [form](screenshots/almarai-rollout/project-form-ar-390.jpg) | Name-only, no mandatory organization |
| Populated project summary | ar/1440 | [summary](screenshots/almarai-rollout/project-summary-ar-1440.jpg) | Recorded1000, netpaid400, remaining600 |
| Project movement report after source/back | ar/1440 | [report](screenshots/almarai-rollout/project-report-back-ar-1440.jpg) | Project/type/lifetime date basis preserved |
| Organization with assigned EQ38 | ar/390 | [organization](screenshots/almarai-rollout/organization-ar-390.jpg) | Count1; project remains independent |
| Archive confirmation | ar/390 | [dialog](screenshots/almarai-rollout/organization-archive-dialog-ar-390.jpg) | Existing dependency explanation |
| Blocked archive | ar/390 | [error](screenshots/almarai-rollout/organization-archive-blocked-ar-390.jpg) | Recaptured after localized error mapping; remains active |
| Same original financial entry | ur/390 | [finance](screenshots/almarai-rollout/entry-refunded-ur-390.jpg) | 1000/600/200/400/600, RTL + mixed name |
| Current renewed insurance | ur/390 | [document](screenshots/almarai-rollout/document-ur-390.jpg) | Current2027, new version has no attachments |
| Receipt-first draft | ur/390 | [draft](screenshots/almarai-rollout/draft-ur-390.jpg) | Unique unposted draft, actual ready file |
| Native expense form/software keyboard | ur/iPhone17Pro | [iOS keyboard](screenshots/almarai-rollout/ios-expense-ur-keyboard.png) | Actual app restored session;123.45 unsaved, software keyboard |
| Native unsaved dialog | ur/iPhone17Pro | [iOS dialog](screenshots/almarai-rollout/ios-unsaved-ur.png) | Left safely; PRE final P3 Leave-color fix, see final web image below |
Native window PNGs include simulator chrome (774×1666); native keyboards/system viewers are not app-controlled typography. No image generation or fake fixtures injected into the production app.


## Final review fix and gap closure (25a65bf + final visual fix)
| Screen | Locale / role / viewport | File | Evidence |
|---|---|---|---|
| Login | ar / unauthenticated /390×1000 | [login](screenshots/almarai-rollout/login-ar-390.jpg) | Actual local development login, no SMS |
| Notifications | en / synthetic OWNER0030 /390×1000 | [notifications](screenshots/almarai-rollout/notifications-en-390.jpg) | Six pre-existing rows; not marked read |
| Equipment form | ar / synthetic OWNER0802 /390×1000 | [form](screenshots/almarai-rollout/equipment-form-ar-390.jpg) | Name/model only, sample discarded without save |
| Unsaved confirmation, FINAL | ar / synthetic OWNER0802 /390×1000 | [fixed dialog](screenshots/almarai-rollout/unsaved-fixed-ar-390.jpg) | P3 review fix: Leave is semantic destructive color |

Final self-review covers latest teamEN1440/UR390 replacements. Independent review inspected four baseline +14 rollout images named in its report, not every image in this index; newer gap-closure/fix images are self-reviewed only. No complete manual matrix claim. [Review details](ALMARAI_ROLLOUT_DELIVERY.md).

## CI follow-up — explicitly PREVIEW evidence
[Historical gallery navigation fix](screenshots/almarai-rollout/preview-nav-ci-fix-ar-390.jpg): actual rendered `main_design_preview.dart`, A/Arabic/390×1000, synthetic preview fixtures (not connected production), after0c5ee08 plus12px/600nav fix. Self-inspected for the inherited CI contrast failure only. It is not evidence for production financial journeys. Temporary8086server/tab stopped; real app8081 remains.
