# Current handoff / resume state
Last updated: 2026-09-24 (backend HTTP smoke and PostgreSQL restart passed; Flutter in progress).

## Current reality
- The product handoff and prior visual references are present.
- Initial package had no application source. The actual Spring Boot API is now running against PostgreSQL; one implementer continues the Flutter/automated-tests part of M0/M1.
- Backend compile and fresh Flyway v1 migration passed. Primary executed 25 live HTTP assertions and retrieved the same records/file after PostgreSQL restart. Full M1 acceptance and Flutter/native flow are not yet claimed.
- No remote repository, cloud account, live OTP configuration, production object store or deployment has been created.
- Archive structure/text/config syntax checks are packaging checks only, not application acceptance tests.

## Current milestone/task
M0/M1 task 001 in progress. UI-001 and automated regression/functional checks remain. Owner explicitly requested to finish only this task and stop; do not start M2 afterward.

## Branch and commits
Local branch `work/m0-m1`; original package commit `8aae033`, inspected environment/decisions checkpoint `a09a869`. Backend and evidence work are in the working tree at this checkpoint. No remote configured or pushed.

## Completed implementation
Backend: dev OTP/session and automatic owner workspace, equipment creation/list/detail, exact paid expense+settlement, audit actions, scoped idempotency, authorized local attachment upload/download with content validation and retry states. Native/web Flutter integration is still being implemented. No production providers or team features.

## Tested commands and results
- Implementer: Java 21 + Maven compile PASS; Flyway v1 fresh dev PostgreSQL 17.11 PASS; API startup PASS on `http://127.0.0.1:8080/api/v1/health` (explicit isolated dev, local storage, scanner unavailable).
- Primary: inline Python HTTP harness PASS 25 assertions, recorded in `docs/evidence/API_MANUAL_CHECKS.md`. User 2 synthetic test data only; six concurrent expense replays produced one original and one settlement; file corruption/retry/immutability/logout passed. No session token printed or persisted.
- Primary: `docker compose -f infra/compose.yaml restart postgres` then `up -d --wait postgres` PASS; re-login retrieved same workspace/equipment/expense/settlement and attachment SHA-256. Backend-process restart still pending.
- Native simulator startup PASS (iPhone 17 Pro/iOS 26.5); application install/use NOT RUN yet. Flutter tests/builds and full backend regression suite still pending.

## Known decisions/blockers
See OPEN_QUESTIONS.md. Production provider credentials, hosting and release policy are not supplied.
No invented existing API keys, Flutter project, SDK installation or source repository should be assumed.

## Next exact action
Finish Flutter API integration and automated backend/Flutter tests, then run browser desktop/mobile-width and native simulator flow, cross-workspace negatives and backend restart. Primary owns docs/Git and manual QA; implementer owns application/contracts/tests; existing reviewers only for current task verification. API is held by implementer Maven session 56922 (Java PID 12206 at this checkpoint); coordinate before stopping. Dev and test PostgreSQL containers remain healthy. User 1 is still untouched for first UI onboarding; user 2 holds the API smoke fixture. No work is promised after this active run ends.

## Next update template
Date/session; branch/commit/diff; completed task IDs; changed files; actual test commands and pass/fail/not-run;
URLs genuinely running in this environment; temporary services running; known defects; pending decisions;
next task and command; owner action strictly needed. Exclude credentials and signed file URLs.
