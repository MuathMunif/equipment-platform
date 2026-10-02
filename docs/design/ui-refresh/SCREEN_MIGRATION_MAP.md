# Migration map — A approved, Equipment Detail pilot complete

Owner approved A on 2026-10-02. Only EquipmentDetail has been migrated in this pilot; the remaining rows are proposed order for later owner approval. Services/backend/router architecture remain unchanged.

| Current presentation | Preview study | Later bounded migration |
|---|---|---|
| `reports.dart: DashboardSection` + `main.dart: EquipmentList` | `OwnerPreview` | Owner home hierarchy, attention sources, period/basis labels; preserve capabilities and M7 requests |
| `main.dart: EquipmentDetail` / `LedgerPage` | `EquipmentPreview` A | **Pilot complete:** scoped A, existing actions/history/access and real API; see PILOT.md |
| `main.dart: ExpenseForm` | `ExpensePreview` | Selected equipment, payment-state visibility, optional details; wire existing validation/controllers without replacing domain rules |
| `main.dart: EntryDetail` | `StatePreview` + `MoneyPreviewRow` | Lifetime totals and all load/permission/attachment states; preserve refunds and settlement contracts |
| `team.dart: DriverHomePage` | Source inspected; not redesigned in this sprint | Later selected-direction adaptation only; retain assigned equipment, issue and submission actions |
| Current app theme / l10n | `DesignTokens` + existing ARBs | Extract chosen tokens only, retaining ar/en/ur and normal account locale handling |

Prototype limits: secondary actions may open a labeled synthetic detail/notice rather than a complete workflow. Shared expense preview has two fixed fixture equipment allocations; it is not a replacement for production allocation editing. Gallery locale is transient and never updates the account.

Stop at Equipment Detail pilot review. Suggested later sequence: ExpenseForm → EntryDetail → equipment list/owner home. Each requires separate authorization and its own real-state checks. Do not transplant fixtures into production.
