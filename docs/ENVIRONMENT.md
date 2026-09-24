# Environment inventory
Initial state: NOT INSPECTED on the user's computer.
Do not replace placeholders with guesses. Record actual version/check output and date.

| Item | Actual state/version | How verified | Next action |
|---|---|---|---|
| OS / architecture | NOT CHECKED | — | Inspect host |
| Git / repository / user author config | NOT CHECKED | — | Preserve existing state; no global changes |
| Java / Maven or wrapper | NOT CHECKED | — | Verify compatible supported versions |
| Flutter / Dart | NOT CHECKED | — | Verify installed SDK and platforms |
| PostgreSQL / test database | NOT CHECKED | — | Establish isolated local persistence |
| Docker / test runtime | NOT CHECKED | — | Use only if available/approved |
| S3-compatible local test storage | NOT CHECKED | — | Verify maintained option and setup |
| File type validation / scanning | NOT CHECKED | — | Implement real checks; label any dev stub |
| Android SDK / emulator/device | NOT CHECKED | — | Report availability |
| Xcode / iOS simulator/device/signing | NOT CHECKED | — | Report availability, no invented signing account |
| Browser test tool | NOT CHECKED | — | Choose supported tool |
| OTP adapter | NOT CONFIGURED | — | Explicit dev-only adapter; production separate |
| Push transport | NOT CONFIGURED | — | Dev sink; live transport later |

## Commands after setup
Write actual tested setup/start/stop/test/migrate/seed/reset commands with working directories.
A suggested command is not an executed command. Specify host platform and required dependencies.
Destructive reset scripts must target clearly disposable dev/test resources and require explicit intent.

## Selected dependency versions
Package + exact version + reason + official source + verification date + license note when relevant.
Do not persist floating latest tags as a reproducible environment.
