#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root/backend"
export MAVEN_USER_HOME="$project_root/.local/maven-user"
exec ./mvnw -B -ntp -Dmaven.repo.local="$project_root/.local/m2" spring-boot:run -Dspring-boot.run.profiles=dev
