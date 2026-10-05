# Verification — compact three-screen refinement

Baseline8d99179, branchfix/home-dashboard-layout,2026-10-05. Existing PR#10 remains the review surface. No independent reviewer; main-only self-review under the active task. Source scope: `app/lib/main.dart` (EquipmentList and _MoreMenu only), `app/lib/reports.dart` (DashboardSection only), new scoped `compact_workspace_layout.dart`, new `app/test/compact_layout_test.dart`, this evidence folder and HANDOFF.

## Actually executed

Commands below run from `app/` unless stated otherwise. Logs are in ignored `.local/`.

| Command | Result |
|---|---|
| `flutter test test/home_layout_test.dart test/reports_test.dart test/almarai_rollout_test.dart --reporter expanded` |58PASS, including successful-empty/nonempty/failure attention, three-row source navigation, old-workspace isolation, month semantics, resize search and uncertain-save regression. `.local/compact-targeted-initial.log` |
| `flutter test --no-pub test/compact_layout_test.dart --dart-define=COMPACT_LAYOUT_EVIDENCE=true --reporter expanded` |17PASS final; one search control/keyboard/explicit queries/pagination/workspace path/detail/add; empty/retry/read-only creation; seven More destinations/order/back/selection and restricted-only-settings; same Almarai400/700/Plex/scale; amount/name text role unchanged; 12locale×size/scale combinations across all3screens and last-row reachability. `.local/compact-targeted-final.log` |
| `flutter test --no-pub --reporter expanded` |248PASS,0FAIL,0SKIP. Full suite run once after production code was final. `.local/compact-full-flutter.log` |
| `flutter analyze --no-pub` |Final clean. `.local/compact-analyze-final.log` |
| `flutter build web --release --no-pub -t lib/main.dart --output=../.local/almarai-rollout/web-production` |PASS. Existing server reused. `.local/compact-web-build.log` |
| `flutter build ios --simulator --debug --no-pub -t lib/main.dart --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1` |PASS,11.2s Xcode build. `.local/compact-ios-build.log` |
| `xcrun simctl install 657C142E-E597-481F-B8F9-8C07082C1D30 app/build/ios/iphonesimulator/Runner.app` (root) |PASS, existing app data retained |
| `xcrun simctl launch --terminate-running-process 657C142E-E597-481F-B8F9-8C07082C1D30 com.equipment.equipmentApp` (root) |PASS; real Home/equipment/More rendered in existing owner session |
| `git diff --check` (root) |PASS |
| Python hashlib check of `FONT_BASELINE.json` and source-range comparison against baseline |13/13 identical; global fonts/palette/pubspec/assets and non-target source sections unchanged |
| `curl --max-time 5 -s http://127.0.0.1:8080/api/v1/health` (root) |UP / ISOLATED_DEVELOPMENT / LOCAL_FILESYSTEM |

The existing web service was reused; its already-tried command from repository root is `python3 -m http.server 8081 --bind 127.0.0.1 --directory .local/almarai-rollout/web-production`. Do not launch a second copy while8081 is occupied. Native and web use existing API8080 and development PostgreSQL55432; no database/session injection or reseeding.

## Earlier failures and exact handling

- New test first run:2PASS/15FAIL. Harness compared raw ThemeData against Flutter's locale-resolved inherited TextStyle, looked for standard NavigationBar rather than existing EquipmentNavigationBar, and asserted hit positions before a post-scroll frame.
- Second run:11PASS/6FAIL: scaled harness tried to tap View all before the scroll frame completed. Added `pumpAndSettle` after scrolling; same navigation expectations retained. Third run17/17PASS. No production correction was needed for these harness failures, no assertion weakened or financial test edited.
- Analyze first pass:3brace-style infos in the new test; added braces only. Final analyze clean. Full suite preceded these non-semantic braces; CI verifies the exact final revision.
- Web build succeeded with existing CupertinoIcons asset warning; iOS succeeded with existing open_filex Swift Package Manager warning. No dependency/platform changes made for either.
- One iOS scroll automation failed due unavailable window handle; reacquiring the app allowed normal tab clicks. No repeated keyboard/OTP loop or private token read. Native lower-home scrolling is not claimed; web lower-home and widget scrolling are verified.

## Visual evidence and scope

[53 actual captures with provenance](screenshots/INDEX.md). Supplied5images inspected separately. Connected data remained owner / مساحتي / October2026 with2equipment,2850expenses,4500income. Arabic390 and desktop1440 live web; native existing iPhone17Pro. Harness ar/en/ur each390×100%,320×160%,320×200%,1440×100%, long names, intact scaling and natural scrolling. Existing real EQ37 name mixes Arabic/Latin; internal references retain LTR glyph order and directional-start alignment.

No local backend campaign; CI may run existing backend tests normally. Final Android build/run not completed because of disk capacity. Physical-device testing, interactive screen-reader testing and native Urdu linguistic review remain pending. No production/provider integration, deployment or final user acceptance claimed.
