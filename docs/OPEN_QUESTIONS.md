# Open questions and decision gates
These are not reasons to stop all development. Continue unrelated approved work.
Never relabel an unresolved business rule as approved. Present concise options and a recommendation at its gate.

| ID | Question | Due before | Safe interim behavior |
|---|---|---|---|
| Q-01 | Does a returned payment reduce the original obligation, reopen it, or represent only return of excess/error? How are partial returns represented? | Refund functionality / milestone M4 | Keep genuine cash history; do not silently reopen/write off debts; implement unrelated finance tasks |
| Q-02 | How may a posted shared allocation or total change after real settlements exist? | Enabling these edit paths in M4 | Block the ambiguous edit with explanation; allow non-financial note/attachment corrections |
| Q-03 | Rejection reason, requester re-submission, and editing an already approved driver-origin entry | Team review in M6 | Preserve history; no silent self-approval or changing recognized money through pending edits |
| Q-04 | If equipment moves between organizations, who sees historical finance/documents? | Organization reassignment in M7 | Do not silently reassign historical ownership/visibility; no mass permissions rewrite |
| Q-05 | Exact basic project/contract fields and association lifecycle | Project/contract UI in M7 | Keep optional relationship concept; do not invent rentals, billing schedules or a contracting engine |
| Q-06 | SMS OTP provider, cost, delivery regions and credentials | Live authentication | Isolated local adapter only; production must reject dev bypass |
| Q-07 | Object storage/provider/region/database hosting/backup retention and costs | Hosted environment or real user data | Local disposable setup; no purchase or data transfer without owner decision |
| Q-08 | Account deletion, workspace closure, ownership transfer and retention obligations | Real accounts / store release | No cascade deletion of a workspace on member account deletion; no claims of legal compliance |
| Q-09 | Phone change/recovery when old number is inaccessible; support identity verification | Live launch | Design state and service boundary; no insecure support backdoor |
| Q-10 | Pricing, subscriptions, quotas and billing policy | Commercial release | No fake paid plans/paywall/payments; keep development unrestricted with explicit upload safety limits |
| Q-11 | Final product name, logo, domain, store IDs/accounts | Publishing | Neutral working title «إدارة المعدات»; no paid domain or finalized branding assumed |
| Q-12 | Exact financial audit visibility and manager/accountant permission matrix | Authorization expansion M6 | Deny unspecified privileged actions; owner retains own-workspace abilities |
| Q-13 | Reminder recipient changes, weekly timing, catch-up after downtime | Notification scheduling M5/M6 | Document a deterministic deduplicated proposal; never send a burst or notify former members |
| Q-14 | Supported image formats (including phone formats), upload size/count limits | Upload UI/API contract M2 | Pick conservative documented dev defaults and disclose unsupported types; confirm production limits |

## Reversible engineering defaults (document, normally do not interrupt owner)
Package names, internal ID format, standard pagination, tested stable dependency versions, layout breakpoints,
non-business error codes, secure implementation patterns and exact-decimal serialization.
Minor-unit rounding must be deterministic, tested and described; it must not violate the approved proportional allocation.
Do not treat a reversible library choice as permission to change platform or backend architecture.

## Asking well
Group related questions, cite the affected task, give two or three understandable options, recommend one,
and say which work can continue. No repeated questions about already confirmed basics.
