# Migration map — selection pending

Nothing below authorizes migration yet. Normal `lib/main.dart`, router, services and backend remain unchanged.

| Current presentation | Preview study | Later bounded migration |
|---|---|---|
| `reports.dart: DashboardSection` + `main.dart: EquipmentList` | `OwnerPreview` | Owner home hierarchy, attention sources, period/basis labels; preserve capabilities and M7 requests |
| `main.dart: EquipmentDetail` / `LedgerPage` | `EquipmentPreview` | Compact identity/actions and grouped sections; preserve archive/history and authorization |
| `main.dart: ExpenseForm` | `ExpensePreview` | Selected equipment, payment-state visibility, optional details; wire existing validation/controllers without replacing domain rules |
| `main.dart: EntryDetail` | `StatePreview` + `MoneyPreviewRow` | Lifetime totals and all load/permission/attachment states; preserve refunds and settlement contracts |
| `team.dart: DriverHomePage` | Source inspected; not redesigned in this sprint | Later selected-direction adaptation only; retain assigned equipment, issue and submission actions |
| Current app theme / l10n | `DesignTokens` + existing ARBs | Extract chosen tokens only, retaining ar/en/ur and normal account locale handling |

Prototype limits: secondary actions may open a labeled synthetic detail/notice rather than a complete workflow. Shared expense preview has two fixed fixture equipment allocations; it is not a replacement for production allocation editing. Gallery locale is transient and never updates the account.

Before integrating the chosen direction: identify one bounded production screen, reuse its real state and access checks, verify actual flows, and preserve the merged date-only fix. Do not transplant fixture logic into production.
