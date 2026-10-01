# Active task — Direction A typography selection checkpoint

- **A layout approved; current Noto font rejected; F1/F2/F3 READY FOR SELECTION; FULL ROLLOUT PAUSED.** Production default unchanged.
- Branch `feat/ui-a-typography`, source clean pilot `ca6201d`. HEAD of this branch carries the comparison/checkpoint; read `git log -1 --oneline` for its SHA. Pilot, date fix, old previews preserved. No main/merge/PR/deployment.
- Completed: preview-only font switcher, reused pilot equipment widgets + existing ExpensePreview, identical synthetic content, real400/700 faces. F1 Plex, F2 Tajawal (whole Urdu locale Plex), F3 Almarai. Rejected Noto explicitly labelled baseline. Source/OFL/hash records included; font binaries unmodified.
- Evidence: **20 actual JPEGs** in `screenshots/typography/`:12 Arabic390/1440 +7 bounded web language/specimen/320-text160% samples +F3/ar iOS. All visually self-inspected. Index, comparison and commands: [TYPOGRAPHY.md](TYPOGRAPHY.md).
- Actual checks: initial focused80/80 (24 typography+36 preview+20 pilot); final typography25/25 after device-scaling fix; analyze clean; preview and production web release +iOS simulator debug pass. Six font HTTP200 responses; distinct rendered family/weight pixels; twelve bundled source/license/metadata hashes verified; production19-file import graph excludes preview.
- Accessibility fix composes the lab multiplier with device scaling. Final F2/expense1440 render byte-matches earlier capture at device1x. No fixed text heights or shrinking to mask overflow.
- Existing iPhone17 Pro simulator runs F3 Arabic preview. Initial terminate returned “nothing to terminate”; install/launch succeeded. No auth/API/database work, new tools, global installs, or dependency upgrades.
- Main sole writer/self-reviewer, **0 subagents**. Existing user-approved Astra/High exception; no model/config changes or repeated identity investigation. Runtime telemetry not independently exposed.
- Limits: no full-suite/backend campaign, Android/physical device/full native matrix, interactive screen reader or human Urdu approval. Exact glyph attribution not proven. New font binaries add912,764 bytes to shared asset bundle; production does not register/use the candidates. Existing Cupertino/open_filex build warnings remain.
- **Next concrete action: owner selects F1/F2/F3. STOP.** Recommend F3 as a visual opinion only. Applying the selected font to the pilot requires the next bounded authorization; no automatic full rollout.

---

# Direction A — Equipment Detail pilot review checkpoint

- **A / واضح وهادئ approved by the owner, 2026-10-02.** B/C remain unselected development-preview references. One production screen migrated; no full-app rollout.
- Branch: `feat/ui-a-equipment-pilot`. Source baseline: clean `feat/ui-design-directions` at `1f8ac5dc2d3f04eb409315ae774f520831d9dec4`. Pilot implementation/checkpoint is carried by this branch HEAD; read `git log -1` for its commit. No reset/stash/merge/main changes.
- Completed: real EquipmentDetail with scoped A design system, existing Ledger state/actions, optional-context loading/error/retry, ar/en/ur resources, responsive layout. Production import graph19 local files excludes preview. Preview remains available separately.
- Evidence:10 actual JPEGs in `screenshots/pilot/`: before ar390/ar1440; after ar390/ar1440/en390/ur390; mobile financial history; empty ar1440/ur390; iOS Arabic. Index: `SCREENSHOTS.md`.
- Actual checks: focused19 passed then a twentieth contrast regression included in final full suite; related76 passed; **full Flutter156/156 passed once**, analyze clean, production web release and iOS simulator debug passed, diff whitespace check passed. Initial overflow/lint failures fixed; see `PILOT.md` for exact commands and limits.
- Real API/PostgreSQL17.11, schema21 current/no migration. Existing synthetic owner0500000802, normal dev auth. New synthetic EQ-000037 populated and EQ-000038 empty. No real customer data, bypass or production credentials.
- Docker recovered only after owner-approved restart; normal restart timed out, supported force-stop/start succeeded with volumes retained. API log `.local/ui-refresh/pilot-api-restarted.log`; web8081 serves `.local/ui-refresh/web-pilot`. Preview8084 retained.
- Main sole writer, user-authorized Astra/High temporary exception; no runtime identity telemetry exposed, no private investigation/config change. One independent read-only child `pilot_visual_review`, requested `gpt-6-astra/high`, limited context/no nesting, after actual renders. No actionable visual findings; full limits in `PILOT.md`.
- Untested: Android/physical device/full native matrix, interactive screen reader, human Urdu approval; restricted/error/160% states verified in widget tests, not all captured live. No backend suite rerun or deployment.
- **Next concrete action: owner reviews the pilot. Stop.** Recommended next bounded migration after approval: add-expense form, then entry detail, then equipment list/home. Do not resume old milestone tasks or automatically migrate another screen.

Full pilot evidence and exact run commands: [PILOT.md](PILOT.md). Historical preview evidence below is preserved and is not pending work.

---

# Historical preview sprint checkpoint — superseded by A approval

## Current task and Git baseline
- Active task completed: three runnable isolated Flutter directions. **Owner selection pending; production restyling has not started.**
- Branch: `feat/ui-design-directions`. Implementation/evidence base commit: `eeadef0`; later commits record delivery metadata and a bounded narrow-width alignment fix. Pushed to the existing `origin/feat/ui-design-directions`; no PR, merge, main push or deployment.
- Source baseline: `8aae24fddf37ec39d5a93b475e4a65a82d406923`, equal to freshly fetched `origin/main` on 2026-10-01. Initial worktree was clean. No reset/stash/cherry-pick or write on main.
- Date serialization fix `8c29ebf` and its tests `649bb3a43cea7e5973ebce15b5f49d079a5b4468` are already merged; ancestor check passed. No backend changes or repeated date acceptance campaign.

## Delivered
- A Clear, B Industrial, C Warm: owner home, equipment detail, add expense; shared components/state screen.
- Entry: `app/lib/main_design_preview.dart`. Direction/locale/viewport/text-scale controls; deterministic synthetic fixtures; no API client instantiated or writes.
- ar/en/ur: 39 new preview localization keys per locale. Exact formatter and date-only semantics reused. Optional contexts remain optional.
- 29 actual JPEG screenshots:18 primary images (390×1000 /1440×1000) +11 focused language/text/state/native images in `screenshots/`; individual links in `SCREENSHOTS.md`.
- One independent reviewer inspected 22 images, recommended B, identified three P2 issues. Fixed compact mobile context, collapsible attachment experiment, control-border contrast. Post-fix checks/screenshots are lead self-review. Details in `DIRECTIONS.md`.

## Model/agent policy
- User-reported main UI selection: Astra / High. Supported runtime identity/effort telemetry was not exposed; no private logs/credentials searched.
- Inspected project default remains `gpt-6-sol / low` and max concurrent subagents 1. `.codex`, `AGENTS.md` and global configuration unchanged.
- Main wrote all implementation. Exactly one child: `ui_visual_review`, default role, explicitly requested `gpt-6-astra / high`, narrow context, read-only, no nested agents. No forced Sol/Luna role used. Child runtime identity likewise not independently exposed.
- Temporary exception applies only to this sprint. No temporary config files to restore; no permanent expensive policy added. No further work until owner selection.

## Commands actually executed
From `/Users/muath/Desktop/equipment-platform/app`:

```sh
flutter gen-l10n
dart format lib/design_preview lib/main_design_preview.dart test/design_preview_test.dart
flutter analyze
flutter test test/design_preview_test.dart --reporter expanded
flutter test --reporter expanded
flutter build web --release -t lib/main_design_preview.dart --output=../.local/ui-refresh/web-preview
flutter build web --release -t lib/main.dart --output=../.local/ui-refresh/web-production
flutter build ios --simulator --debug -t lib/main_design_preview.dart
```

Preview server (from repository root), actually running during delivery:

```sh
python3 -m http.server 8084 --bind 127.0.0.1 --directory .local/ui-refresh/web-preview
```

Open `http://127.0.0.1:8084/?direction=b&screen=home&locale=ar`. Supported query values: `direction=a|b|c`, `screen=home|equipment|expense|states`, `locale=ar|en|ur`, `scale=1|1.3|1.6|2`. Gallery viewport controls cap available width; they do not enlarge a smaller host window. Scroll to content below the viewport. The sliders icon opens developer controls.

Native commands executed from repository root (existing booted simulator):

```sh
xcrun simctl install 657C142E-E597-481F-B8F9-8C07082C1D30 app/build/ios/iphonesimulator/Runner.app
xcrun simctl launch 657C142E-E597-481F-B8F9-8C07082C1D30 com.equipment.equipmentApp
```

## Actual checks and results
| Check | Result |
|---|---|
| Normal Flutter suite, run once at completed implementation checkpoint | **133 passed** = 100 existing +33 preview |
| Final targeted preview suite, after adding review regressions | **36 passed**; includes three additional tests, not another full-suite run |
| Flutter analyze | **PASS**, no issues |
| Preview web release / normal web release / iOS simulator debug | **PASS** |
| Arabic 3 directions ×3 screens ×390/1440 | Rendered, saved and visually inspected |
| Widget layout matrix | 18 primary sizes +9 direction/locale cases cycling all4 screens at320/1.6; no overflow exceptions |
| Money/status/form behavior | Full default, partial amount+party validation, unpaid party, cancel guard, exact shared sum/general scope, retry retains input, unavailable ≠zero |
| Accessibility | Arabic A home tap-target/label/text-contrast guidelines pass; all direction control outlines >=3:1; keyboard inset test confirms amount and action can scroll into visible area |
| Native | iPhone17 Pro /iOS26.5: owner→equipment→expense; focused amount visible above numeric keyboard; preview result explicitly says nothing saved; two actual window screenshots |
| Isolation | Production local-import graph (16 files) excludes preview; built production JS lacks developer gallery markers; backend/API/router/math/auth/config unchanged |
| Locale/Git hygiene | 39 preview keys match ar/en/ur; `git diff --check` passed; generated l10n files are intentional; ignored builds/logs stay `.local` |

Additional browser self-checks: English LTR expense, Urdu RTL B home, C Arabic320 at160%; partial/unpaid fields and validation; simultaneous load/attachment failure; direction/locale/viewport controls. Native keyboard visibility was temporarily toggled and restored; no hardware-keyboard/language/model/global config changed.

## Failures encountered, resolved / limitations
- Initial Dart parse error and four string-placeholder type errors were fixed before first successful build/analyze.
- First preview test run:32 passed/1 failed because test SemanticsHandle cleanup happened too late. Fixed; next33 passed. Added regression test initially referenced a nonexistent TextFormField getter; corrected to rendered TextField; targeted35 passed, then36 passed after the narrow-width regression test.
- Sandboxed server/simulator access required approved execution. First native launch guessed wrong bundle ID and failed; read actual built Info.plist ID and launched successfully.
- Native CUA scrolling/window-screenshot methods sometimes returned `noWindowsAvailable`; state-and-screenshot/AX actions worked. Native gesture-scrolling with keyboard is **not claimed verified**; widget visible-area check passed.
- Existing Flutter tool emitted its own failed version tag fetch; SDK remained3.47.2 /Dart3.13.2. Web builds warn about existing secure-storage WASM incompatibility/missing Cupertino font expectation; JS release builds pass. iOS warns existing plugins need future Swift Package Manager adoption. No upgrades performed.
- No live authenticated baseline (8080/8081 not listening), backend/end-to-end campaign, Android preview run, physical-device test, all-language/all-native matrix, human Urdu linguistic approval, production rollout, or full-app restyling. Native rendering is A/Arabic only.
- Preview fonts add about1.64MB uncompressed to shared asset bundle; production typography unchanged. Consider preview-only asset packaging during chosen-direction integration.

Final delivery self-check found centered, intrinsic-width finance cards at320px. Stacked cards now stretch to content width; a dedicated280px card-width assertion passes. Primary390/1440 renders are unaffected. Native sample predates this320px-only home adjustment; no broader native matrix is claimed.

## Next concrete action
Owner chooses A/B/C (recommend B). Then authorize a bounded first production-screen migration using its existing real state and access rules. **Stop here; no new milestone or automatic continuation.**
