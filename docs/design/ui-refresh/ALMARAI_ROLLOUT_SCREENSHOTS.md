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
| Language dialog |390|[language](screenshots/almarai-rollout/language-dialog-ar-390.jpg)|Pre-width-fix: font verified, final minWidth280 recapture pending|

EN/UR connected forms, native, other families and final review still pending. Widget ar/en/ur results are not connected screenshots.

## Batch2 — connected production / synthetic OWNER
Actual images captured and self-inspected: `refund-dialog-ar-390.jpg`, `entry-refunded-ar-390.jpg`, `entry-refunded-ar-1440.jpg`, `entry-history-attachment-ar-390.jpg`, `receipt-viewer-ar-390.jpg`, `report-recorded-ar-1440.jpg`, `report-movements-ar-1440.jpg`, `report-outstanding-ar-390.jpg` in `screenshots/almarai-rollout/`. Financial detail images predate final amount-edge alignment and attachment-margin correction; recapture before final review. Reports show real current synthetic data; outstanding is all-time current600, not an October snapshot. Receipt image350 is an existing generic synthetic attachment, not a calculation input for entry1000.

## Batch3 source (after1d6b36e, current batch3 changes)
Connected OWNER/en/390×1000 actual self-inspected: [finance](screenshots/almarai-rollout/entry-refunded-en-390.jpg) latest valuealignment; [document](screenshots/almarai-rollout/document-en-390.jpg), [renewform](screenshots/almarai-rollout/document-renew-en-390.jpg), [oldreadonly](screenshots/almarai-rollout/document-history-en-390.jpg), [protectedoldfile](screenshots/almarai-rollout/document-old-attachment-en-390.jpg). Historicalattachmentname/frame are app-controlled Almarai; imagecontents are syntheticfixture.

## Batch4 source (after3c5590c, current batch4 changes)
Connected OWNER/en actual inspected: [openissue390](screenshots/almarai-rollout/issue-open-en-390.jpg), [linkedmaintenance1440](screenshots/almarai-rollout/maintenance-linked-en-1440.jpg), [closedissue390](screenshots/almarai-rollout/issue-closed-en-390.jpg). Height1000. Hover tint on relatedmaintenance row is pointerstate. No preview or duplicatedfinance.
