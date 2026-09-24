#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root/app"
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
exec python3 -m http.server 8081 --bind 127.0.0.1 --directory build/web
