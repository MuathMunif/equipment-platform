# FIRST-001 — owner alone, one equipment, one expense and one attachment
Status: DONE — local M0/M1 slice, 2026-09-24. V1 and production readiness remain incomplete. Stop here per owner's latest instruction.

## Execution checkpoints
| Task | Status | Actual evidence |
|---|---|---|
| ENV-001 | DONE | ENVIRONMENT.md; original package preserved in local commit 8aae033 |
| BASE-001 | DONE | Backend/Flutter builds, Flyway V1 and wrapper, isolated PostgreSQL dev/test |
| AUTH-001 | DONE | Dev OTP, auto-workspace, session/CSRF/revocation negatives and real web onboarding |
| EQ-001 | DONE | Name + textual model only; UI create/retrieve; idempotency and tenant checks |
| FIN-001 | DONE | Exact 350.00, one original and settlement; six concurrent retries; date separation |
| FILE-001 | DONE for local adapter | Corrupt/retry/immutability/auth checks; receipt visible after restart; S3 and malware scanner NOT TESTED |
| UI-001 | DONE | Arabic RTL; web 1280/390 flow; native iOS simulator integration PASS |
| CHECK-001 | DONE | 12 backend + 7 Flutter + 1 iOS test PASS, live HTTP/browser checks, independent source/UX reviews |

Evidence: `../evidence/M1_ACCEPTANCE.md`; known non-blocking UX date-direction issue and untested platforms are explicitly recorded. No acceptance text below was relaxed.

## Outcome
The owner can run the application locally, authenticate via an explicitly isolated development OTP flow,
create equipment with only name and model, save a fully paid expense with an attachment, and find it after refresh.
The same permitted flow has mobile-appropriate and desktop-appropriate Flutter layouts backed by the actual API/database.
No separate accountant/team/organization/project setup is necessary.

## Sequence
ENV-001: Inspect folder/Git/toolchain; record actual versions and commands; preserve existing files.
BASE-001: Backend/app skeleton, PostgreSQL schema/migrations, tests and development profiles.
AUTH-001: Dev OTP adapter with production fail-closed boundary, sessions, user/workspace ownership.
EQ-001: Create/list/detail equipment with server-side access control and idempotent create.
FIN-001: One fully paid expense with a real original+settlement transaction; exact money; details and list.
FILE-001: Attach a supported file, store metadata separately, authorize upload/read, reflect upload state/failure.
UI-001: Arabic owner onboarding/equipment/entry/ledger interfaces wired to API, not fixed in-memory demo data.
CHECK-001: Independent review if available, actual functional/negative checks, screenshots and resumable HANDOFF.

## Minimum demonstrated scenario
Start from an empty dev workspace. Create «قلاب ١» with model «2021»; optional fields remain absent.
Record a 350.00 SAR paid fuel expense; attach a synthetic test receipt. Refresh, open equipment, find the expense.
Download/view the attachment through authorized access. Retry a save request and demonstrate one financial original only.
Use a second isolated dev user/workspace to attempt access by equipment/entry/file ID; deny it without leaking content.
Stop/start documented supported services and verify persistent data has not vanished.
Use synthetic data only; no scraped real invoice, real SMS, production credentials or public file bucket.

## Required evidence
Test output/commands + environment + actual screenshots at mobile and desktop width, startup instructions and limits.
Record which native devices/platforms were actually exercised; browser width is not iOS-device validation.
If a provider is represented by a dev adapter, label the integration accordingly and keep production readiness incomplete.

## Not in this initial slice
Full V1 team/reviews, refunds, shared distributions, final push delivery, advanced projects/contracts,
commercial subscriptions, production deployment, GPS or accounting. These are not discarded; use the milestone backlog.

## Acceptance references
AUTH-01/03/04/05, EQ-01/02/03/04, FIN-02/06/20, FILE-01/02/04/05, TEN-01/02, UX-01/02/03/04/05, OPS-01/02/03.

## Handoff target
A runnable honest local slice. Not a claim of V1 completion. Report exact next task in M2 and remaining release gates.
