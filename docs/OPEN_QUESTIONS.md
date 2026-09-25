# Open questions and decision gates
These are not reasons to stop all development. Continue unrelated approved work.
Never relabel an unresolved business rule as approved. Present concise options and a recommendation at its gate.

| ID | Question | Due before | Safe interim behavior |
|---|---|---|---|
| Q-01 RESOLVED 2026-09-24 | Owner chose: refunds reduce net settled and increase remaining against unchanged original total, for both expense and income; preserve original settlements | M2 refund slice | Decision D-19 in `04_DECISIONS_AR.md`; test 1000 total / 600 paid / 200 refunded => 400 net paid / 600 remaining |
| Q-02 RESOLVED 2026-09-24 | Owner decided: before any financial movement, total and expense classification may change; after the first settlement/refund, total is immutable for EXPENSE/INCOME while active expense allocations/classification may be corrected at the same total | M2 functional boundary | Decision D-20 in `04_DECISIONS_AR.md`; preserve settlement/refund rows, require exact allocation sum and workspace scope, audit before/after |
| Q-03 PARTIAL M5 | Rejection reason is required and preserves the rejected request; approval creates one linked M2 entry. A correction/re-submission policy for rejected requests and editing an already approved driver-origin entry remains unapproved | Before adding those edit/resubmit flows | Preserve history; no silent self-approval or changing recognized money through pending edits |
| Q-04 | If equipment moves between organizations, who sees historical finance/documents? | Organization reassignment in M7 | Do not silently reassign historical ownership/visibility; no mass permissions rewrite |
| Q-05 | Exact basic project/contract fields and association lifecycle | Project/contract UI in M7 | Keep optional relationship concept; do not invent rentals, billing schedules or a contracting engine |
| Q-06 | SMS OTP provider, cost, delivery regions and credentials | Live authentication | Isolated local adapter only; production must reject dev bypass |
| Q-07 | Object storage/provider/region/database hosting/backup retention and costs | Hosted environment or real user data | Local disposable setup; no purchase or data transfer without owner decision |
| Q-08 | Account deletion, workspace closure, ownership transfer and retention obligations | Real accounts / store release | No cascade deletion of a workspace on member account deletion; no claims of legal compliance |
| Q-09 | Phone change/recovery when old number is inaccessible; support identity verification | Live launch | Design state and service boundary; no insecure support backdoor |
| Q-10 | Pricing, subscriptions, quotas and billing policy | Commercial release | No fake paid plans/paywall/payments; keep development unrestricted with explicit upload safety limits |
| Q-11 | Final product name, logo, domain, store IDs/accounts | Publishing | Neutral working title «إدارة المعدات»; no paid domain or finalized branding assumed |
| Q-12 PARTIAL M5 | M5 defines role defaults, permission overrides, equipment scope, financial DIRECT/REVIEW mode, and owner-only sensitive membership changes. Any additional audit-history visibility policy remains open | Before adding an audit browser or changing M5 grants | Deny unspecified privileged actions; owner retains own-workspace abilities |
| Q-13 | Reminder recipient changes, weekly timing, catch-up after downtime | Notification scheduling after M5 | Document a deterministic deduplicated proposal; never send a burst or notify former members |
| Q-14 | Supported image formats (including phone formats), upload size/count limits | Upload UI/API contract M2 | Pick conservative documented dev defaults and disclose unsupported types; confirm production limits |

## Reversible engineering defaults (document, normally do not interrupt owner)
Package names, internal ID format, standard pagination, tested stable dependency versions, layout breakpoints,
non-business error codes, secure implementation patterns and exact-decimal serialization.
Minor-unit rounding must be deterministic, tested and described; it must not violate the approved proportional allocation.
Do not treat a reversible library choice as permission to change platform or backend architecture.

## Asking well
Group related questions, cite the affected task, give two or three understandable options, recommend one,
and say which work can continue. No repeated questions about already confirmed basics.
