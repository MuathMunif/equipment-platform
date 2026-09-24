# Manual API checks — 2026-09-24

Runner: primary /root; live Spring Boot API http://127.0.0.1:8080/api/v1 and PostgreSQL development DB.
Command: an inline Python 3 urllib HTTP harness (executed via approved tool, exit 0).
Synthetic second development identity only; session tokens were neither printed nor persisted.
25 asserted checks passed; six concurrent save replays used ThreadPoolExecutor.
This record is a transcript of actual checks, not the automated regression test suite.

- PASS: Live API explicitly reports isolated development and no malware scanner
- PASS: Wrong development OTP rejected
- PASS: New owner requires name only after verification
- PASS: Exactly one automatic workspace
- PASS: Consumed challenge cannot be reused
- PASS: Name and text model only; replay keeps equipment ID
- PASS: Equipment idempotency conflict rejects changed payload
- PASS: Equipment requires authentication
- PASS: Unowned workspace is hidden
- PASS: Six concurrent expense replays return one original
- PASS: 350.00 expense has one 350.00 settlement and zero remaining
- PASS: Operation and settlement dates remain distinct
- PASS: Expense payload conflict is rejected
- PASS: Excess precision rejected without rounding
- PASS: System-owned unknown field is rejected
- PASS: Disguised/corrupt image rejected
- PASS: Failed attachment state is persisted
- PASS: Same failed attachment can be retried to READY
- PASS: Authorized original bytes round-trip
- PASS: Upload finalization replay retains same attachment
- PASS: READY original is immutable
- PASS: Attachment is not public
- PASS: Upload failure/retry never changes original money
- PASS: Equipment ledger contains one expense after replays
- PASS: Logout revokes attachment access immediately

PASS: after PostgreSQL dev restart, the same workspace/equipment/entry/one settlement and original attachment SHA-256 were retrieved; login required no new name and no second workspace was created. Backend restart remains pending. Cross-workspace attempts using the first actual demo owner: pending UI onboarding.
