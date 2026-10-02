# HOME correction — current task, awaiting owner visual review

- Branch: `fix/home-dashboard-layout`, source merged main `ef9e6824d5d940b814859e7897827e31a4b07c54`. PR#9 is merged; do not resume its old delivery or switch/reset/stash main.
- Active checkpoint: [HOME_LAYOUT_FIX.md](home-layout-review/HOME_LAYOUT_FIX.md). Read it and git status after compaction.
- Completed: compact real owner/member home; A/Almarai retained; three truthful metrics, conditional attention, three recent entries, three equipment rows, existing navigation/search/permissions preserved.
- Evidence: [13 labeled screenshots](home-layout-review/SCREENSHOTS.md), including8connected and5harness. Original reference files preserved under `docs/design/home-layout-review/`.
- Local checks: targeted45PASS; full Flutter run once230PASS/1FAIL (old home-search assumption), then corrected equipment-resize test1PASS; analyze clean; production web and iOS simulator build/run PASS. Final production code unchanged after full run; final edit was test-only. CI must match final PR head.
- Main sole writer and self-review; no subagents/settings change. Runtime model not independently exposed; preserve owner-reported exception.
- Data/services unchanged, owner0802 restored Arabic/October2026; native home and web8081 display correction. No Android/device/screen-reader campaign or Urdu linguistic approval.
- Next: focused commit/push, fix PR, required CI verification; then STOP for user visual review. No merge, new milestone or UI acceptance on user's behalf.
