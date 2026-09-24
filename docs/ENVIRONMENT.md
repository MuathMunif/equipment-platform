# Environment inventory
Inspected: 2026-09-24 on the owner's authorized project folder. Application checks are tracked separately below and in HANDOFF.
Initial folder contained specification/reference files only, no backend, Flutter application, or Git repository.

| Item | Actual state/version | How verified | Next action |
|---|---|---|---|
| OS / architecture | macOS 26.5.2 (25F84), Darwin 25.5.0, arm64 | `sw_vers`, `uname -srm` | No system changes |
| Git / repository / user author config | Git 2.50.1; initial folder not a repository; author already configured | `git status`, `git --version`, author config presence | Initialized local `work/m0-m1`; original package commit `8aae033`; no remote |
| Java / Maven or wrapper | Host default Java 24.0.1; Maven 3.9.11 uses 24.0.2; Microsoft Java 21.0.7 installed | `java -version`, `mvn -version`, `/usr/libexec/java_home -V` | Use Java 21 only per command, no global configuration change; wrapper 3.3.4 / Maven 3.9.11 tested successfully |
| Flutter / Dart | Flutter 3.47.2 stable (d3b14c8769), Dart 3.13.2 | `flutter --version`, `flutter doctor -v` | Existing SDK at `/opt/homebrew/share/flutter`; no upgrade |
| PostgreSQL / test database | PostgreSQL 17.11 (Debian 17.11-1.pgdg13+2), aarch64; dev/test containers healthy | `docker compose -f infra/compose.yaml --profile test up -d --wait`, `ps`, `psql ... select version()` | Isolated databases on loopback 55432/55433; Flyway V1 applied and validated; HTTP/PostgreSQL tests passed |
| Docker / test runtime | Docker 28.0.4, Compose 2.34.0; initially stopped, now running linux/aarch64 | `docker --version`, `docker compose version`, `docker info` | Docker started via approved `open -a Docker`; do not touch unrelated services |
| S3-compatible local test storage | NOT CONFIGURED / NOT TESTED | No provider provisioned | Explicit dev filesystem adapter under project; S3 integration remains open for M2 |
| File type validation / scanning | PNG/JPEG via ImageIO; PDFBox 3.0.8; real content/size checks tested | Backend regression and live HTTP tests | Malware scanner NOT CONFIGURED; DEV_NOT_SCANNED explicit |
| Android SDK / emulator/device | SDK 36.0.0; emulator binary 37.1.11; cmdline-tools missing, license status unknown; no connected Android device | `flutter doctor -v` | No global SDK install or license acceptance; native checks pending |
| Xcode / iOS simulator/device/signing | Xcode 26.6 (17F113), CocoaPods 1.16.2; installed iOS 17.0/26.5 simulators; initially all shutdown; no physical device | `flutter doctor -v`, approved `xcrun simctl list devices available` / `list runtimes` | iPhone 17 Pro/iOS 26.5 booted; Xcode simulator build and one integration flow PASS; no physical device/signing |
| Browser test tool | Chrome 153.0.8010.53; available computer-use browser tool | `flutter doctor -v` | IAB functional test at 1280x900 and 390x844 PASS; Chrome automation unavailable |
| OTP adapter | Isolated development adapter implemented | Backend tests + web onboarding | Two synthetic identities; production fail-closed; no SMS |
| Push transport | NOT CONFIGURED, outside M1 | — | No FCM credentials, no live delivery claim |

## Codex compatibility and approvals
- Installed CLI: `codex-cli 0.155.0-alpha.16.3`.
- Project `.codex/config.toml` and three role files parse with Python `tomllib`.
- `codex features list` reports `multi_agent` stable/enabled. Actual `implementer` and `ux_reviewer` role spawns succeeded; runtime exposes `reviewer` too.
- Official configuration reference supports `agents.max_concurrent_threads_per_session` (excluding primary), descriptions/config files and read-only sandbox. Runtime has 3 total slots (primary + 2 subordinate).
- `codex --strict-config features list` fails because this subcommand does not support that switch. This is not recorded as config validation success. CLI also emits a sandbox PATH-alias warning; feature inspection still exits 0.
- No `.codex` or global configuration edits, no model overrides, no permission relaxation.
- Flutter initially failed because SDK cache writes are outside the workspace; the same version/doctor command succeeded after approved escalation. Docker GUI launch and Git initialization/snapshot likewise used the actual approval mechanism.

## Commands after setup
Actual tested setup/start/restart/test commands with working directories are recorded in `evidence/M1_ACCEPTANCE.md` and `HANDOFF.md`. No destructive development reset was run.

## Selected dependency versions
Versions were pinned after local and official-source verification; generated lockfiles are retained.

Verified official sources on 2026-09-24:
- [Spring Boot system requirements](https://docs.spring.io/spring-boot/system-requirements.html): 4.1.1 stable, Java 17–26, Maven >=3.6.3. Selected 4.1.1 with Java release 21 and Maven 3.9.11. Existing JDK patch is a local development tool, not an assertion of production security readiness.
- [PostgreSQL version policy](https://www.postgresql.org/support/versioning/): 17.11 is supported; chosen for isolated local DB containers with persistent storage. PostgreSQL License.
- [Flutter stable releases](https://docs.flutter.dev/release/release-notes) and [SDK archive](https://docs.flutter.dev/install/archive): installed stable 3.47.2/Dart 3.13.2 confirmed by SDK command; BSD-3-Clause framework.
- [Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference): supported project/agent settings, checked alongside actual local tool availability.
- [PDFBox official downloads](https://pdfbox.apache.org/download.html): selected 3.0.8 (Apache-2.0) for actual PDF parsing. No malware-scanner claim.
- [Maven Wrapper official goal](https://maven.apache.org/tools/wrapper/maven-wrapper-plugin/wrapper-mojo.html): wrapper plugin 3.3.4; Maven 3.9.11 distribution generated and wrapper test passed.

Dependency resolution, migrations, backend tests, Flutter analysis/tests/web build and iOS simulator integration now PASS. Initial Maven DNS and SDK-cache permission restrictions were resolved through actual approved escalation, not a sandbox/configuration bypass. Full results are in evidence/M1_ACCEPTANCE.md.

## Infrastructure evidence so far
- `docker compose -f infra/compose.yaml --profile test up -d --wait`: PASS (exit 0), both services healthy; only the named project containers/volumes created. Initial unapproved socket call failed and was retried with required escalation.
- `docker compose -f infra/compose.yaml --profile test ps`: PASS; published only `127.0.0.1:55432` and `127.0.0.1:55433`.
- `docker compose -f infra/compose.yaml exec -T postgres psql -U equipment_dev -d equipment_dev -Atc 'select version();'`: PASS, version above.
- Simulator listing initially failed on sandbox CoreSimulator/log access; approved retry succeeded. Listing is not an app build/device validation.

## Final validation checkpoint — 2026-09-24
- Backend: Java 21, Boot 4.1.1, real PostgreSQL 17.11; 12 tests / 0 failures / 0 errors / 0 skipped (latest wrapper run: 2.800 s).
- Flutter: analyze PASS; 7 unit/widget tests PASS; release web build PASS; iOS simulator integration 1 PASS after a harness correction.
- Native build warning: open_filex currently falls back to CocoaPods rather than Swift Package Manager. Build succeeded; future Flutter migration is untested. No SDK upgrades were performed.
- Web build warning about unused CupertinoIcons font was non-fatal; current app uses Material icons.
- Exact tested commands and process restart evidence: evidence/M1_ACCEPTANCE.md.
- Runtime model/reasoning: inherited session defaults with no overrides. Exact model identifier and reasoning level are not exposed by the agent tools; do not infer them from recommended role files.

Flutter dependencies pinned and lockfile retained (official package pages checked 2026-09-24): [http 1.6.0](https://pub.dev/packages/http/versions/1.6.0), [file_selector 1.1.0](https://pub.dev/packages/file_selector/versions/1.1.0), [flutter_secure_storage 11.2.0](https://pub.dev/packages/flutter_secure_storage/versions/11.2.0), [cross_file 0.3.5+5](https://pub.dev/packages/cross_file/versions/0.3.5%2B5), [path_provider 2.1.6](https://pub.dev/packages/path_provider/versions/2.1.6), [open_filex 4.7.0](https://pub.dev/packages/open_filex/versions/4.7.0). These are development dependency selections, not production provider choices.
