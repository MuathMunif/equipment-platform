# Environment inventory
Inspected: 2026-09-24 on the owner's authorized project folder. Application checks are tracked separately below and in HANDOFF.
At initial inspection the folder contained specifications only. It now contains the implemented local application and Git repository; current status is in HANDOFF.md.

| Item | Actual state/version | How verified | Next action |
|---|---|---|---|
| OS / architecture | macOS 26.5.2 (25F84), Darwin 25.5.0, arm64 | `sw_vers`, `uname -srm` | No system changes |
| Git / repository / user author config | Git 2.50.1; initial folder not a repository; author already configured | `git status`, `git --version`, author config presence | Initialized local `work/m0-m1`; original package commit `8aae033`; no remote |
| Java / Maven or wrapper | Host default Java 24.0.1 at latest check; Microsoft Java 21.0.7 installed; Maven Wrapper uses Maven 3.9.11 | `java -version`, JDK 21 `java -version`, backend test command | Set `JAVA_HOME` to Java 21 per command; no global configuration change; wrapper 3.3.4 / Maven 3.9.11 tested |
| Flutter / Dart | Flutter 3.47.2 stable (d3b14c8769), Dart 3.13.2 | `flutter --version`, `flutter doctor -v` | Existing SDK at `/opt/homebrew/share/flutter`; no upgrade |
| PostgreSQL / test database | PostgreSQL 17.11 (Debian 17.11-1.pgdg13+2), aarch64; dev/test containers healthy at latest check | `docker compose -f infra/compose.yaml ps`, `psql ... select version()`, backend tests | Isolated databases on loopback 55432/55433; Flyway V1–V13 validated; dev DB upgraded to V13 without reset |
| Docker / test runtime | Docker 28.0.4, Compose 2.34.0; initially stopped, now running linux/aarch64 | `docker --version`, `docker compose version`, `docker info` | Docker started via approved `open -a Docker`; do not touch unrelated services |
| S3-compatible local test storage | NOT CONFIGURED / NOT TESTED | No provider provisioned | Explicit dev filesystem adapter under project; S3 integration remains open for M2 |
| File type validation / scanning | PNG/JPEG via ImageIO; PDFBox 3.0.8; real content/size checks tested | Backend regression and live HTTP tests | Malware scanner NOT CONFIGURED; DEV_NOT_SCANNED explicit |
| Android SDK / emulator/device | SDK 36.0.0; emulator binary 37.1.11; cmdline-tools missing, license status unknown; no connected Android device | `flutter doctor -v` | No global SDK install or license acceptance; native checks pending |
| Xcode / iOS simulator/device/signing | Xcode 26.6 (17F113), CocoaPods 1.16.2; installed iOS 17.0/26.5 simulators; initially all shutdown; no physical device | `flutter doctor -v`, approved `xcrun simctl list devices available` / `list runtimes` | iPhone 17 Pro/iOS 26.5 booted; Xcode simulator build and one integration flow PASS; no physical device/signing |
| Browser test tool | Chrome 153.0.8010.53; available computer-use browser tool | `flutter doctor -v` | IAB functional test at 1280x900 and 390x844 PASS; Chrome automation unavailable |
| OTP adapter | Isolated development adapter implemented | Backend tests + web onboarding | Two synthetic identities; production fail-closed; no SMS |
| Push transport | Development no-op sender; no live Push | M3 backend tests | In-app notifications persist; FCM/APNs and credentials deferred to pre-Beta |

## Codex compatibility and approvals
- Installed CLI: `codex-cli 0.155.0-alpha.16.3`.
- Project `.codex/config.toml` and three role files parse with Python `tomllib`.
- Earlier `codex features list` reported `multi_agent` stable/enabled; M1 used implementer, reviewer and UX reviewer. No subagent was used for the documented M2 slices or this synchronization.
- Project-local policy now sets main `gpt-6-sol/low`, implementer `gpt-6-sol/medium`, reviewer `gpt-6-sol/low`, UX reviewer `gpt-6-luna/low`, and at most one concurrent subagent. These are configured defaults, not proof of an existing session's effective model/reasoning.
- `codex --strict-config features list` fails because this subcommand does not support that switch. This is not recorded as config validation success. CLI also emits a sandbox PATH-alias warning; feature inspection still exits 0.
- These project-local `.codex` edits are being committed with the approved policy; no global configuration or permission relaxation.
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

Dependency resolution, Flyway V1–V3, backend tests, Flutter analysis/tests/web build and iOS simulator integration have passed locally. Initial Maven DNS and SDK-cache permission restrictions were resolved through actual approved escalation, not a sandbox/configuration bypass. Current M2 evidence is in evidence/M2_EXPENSE_SETTLEMENTS.md and evidence/M2_INCOME_SETTLEMENTS.md.

## Infrastructure evidence so far
- `docker compose -f infra/compose.yaml --profile test up -d --wait`: PASS (exit 0), both services healthy; only the named project containers/volumes created. Initial unapproved socket call failed and was retried with required escalation.
- `docker compose -f infra/compose.yaml --profile test ps`: PASS; published only `127.0.0.1:55432` and `127.0.0.1:55433`.
- `docker compose -f infra/compose.yaml exec -T postgres psql -U equipment_dev -d equipment_dev -Atc 'select version();'`: PASS, version above.
- Simulator listing initially failed on sandbox CoreSimulator/log access; approved retry succeeded. Listing is not an app build/device validation.

## Current validation checkpoint — 2026-09-25
- Backend: Boot 4.1.1 targets Java 21, real PostgreSQL 17.11; Flyway V1–V13 validated in test, existing dev DB upgraded to V13; 56 tests / 0 failures / 0 errors / 0 skipped in the latest run.
- Flutter: analyze PASS; 67 unit/widget tests PASS; release web build PASS. M4 live web journey against local API/PostgreSQL PASS in Chrome. Earlier M3 iOS simulator integration 1/1 PASS (M2 prior 2/2); M4 iOS and Android not run.
- Native build warning: open_filex currently falls back to CocoaPods rather than Swift Package Manager. Build succeeded; future Flutter migration is untested. No SDK upgrades were performed.
- Web build warning about unused CupertinoIcons font was non-fatal; current app uses Material icons.
- Exact earlier setup/restart evidence: evidence/M1_ACCEPTANCE.md; current M2 test and flow evidence: evidence/M2_EXPENSE_SETTLEMENTS.md and evidence/M2_INCOME_SETTLEMENTS.md.
- Runtime model/reasoning for an existing session are not exposed by the agent tools; do not infer them from project role files.

## Local ports and startup requirements
- Docker Compose publishes PostgreSQL dev on `127.0.0.1:55432` and isolated test on `127.0.0.1:55433`; no external database is needed.
- `JAVA_HOME=$(/usr/libexec/java_home -v 21) ./scripts/backend-dev.sh` from the repository root starts the current source on `127.0.0.1:8080` and applies pending Flyway migrations. Stop or restart an older API process before relying on current M4 behavior.
- `./scripts/web-dev.sh` builds the current Flutter web source against `http://127.0.0.1:8080/api/v1` and serves it on `127.0.0.1:8081`; stop or restart an older web server to serve the rebuilt files. Flutter and Dart versions above were rechecked locally.
- The `8082/8083` pair in M2 evidence was temporary for verification and is not a required port pair. Current health or HTTP 200 on `8080/8081` alone does not identify the running commit.

Flutter dependencies pinned and lockfile retained (official package pages checked 2026-09-24): [http 1.6.0](https://pub.dev/packages/http/versions/1.6.0), [file_selector 1.1.0](https://pub.dev/packages/file_selector/versions/1.1.0), [flutter_secure_storage 11.2.0](https://pub.dev/packages/flutter_secure_storage/versions/11.2.0), [cross_file 0.3.5+5](https://pub.dev/packages/cross_file/versions/0.3.5%2B5), [path_provider 2.1.6](https://pub.dev/packages/path_provider/versions/2.1.6), [open_filex 4.7.0](https://pub.dev/packages/open_filex/versions/4.7.0). These are development dependency selections, not production provider choices.
