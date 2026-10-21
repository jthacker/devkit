#!/usr/bin/env bash
# Tests for plugin/scripts/session-start.sh against a fake plugin root and
# fake projects.
set -euo pipefail

hook="$(cd "$(dirname "$0")/.." && pwd)/plugin/scripts/session-start.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/plugin/conventions"
echo 3 > "$tmp/plugin/conventions/VERSION"
cat > "$tmp/plugin/conventions/CHANGELOG.md" <<'MD'
# Conventions changelog

## v3: Third change

## v2: Second change

## v1: First version
MD

failures=0
run() {
  local name=$1 agents=$2 expect=$3
  local project="$tmp/$name"
  mkdir -p "$project"
  if [[ -n "$agents" ]]; then printf '%s\n' "$agents" > "$project/AGENTS.md"; fi
  local out
  out=$(CLAUDE_PLUGIN_ROOT="$tmp/plugin" CLAUDE_PROJECT_DIR="$project" "$hook")
  if [[ "$out" == "$expect" ]]; then
    echo "ok   $name"
  else
    echo "FAIL $name"
    diff <(printf '%s\n' "$expect") <(printf '%s\n' "$out") || true
    failures=$((failures + 1))
  fi
}

run no-agents-file "" ""
run no-marker "# Project" ""
run current "<!-- devkit:begin conventions=3 -->" ""
run behind "<!-- devkit:begin conventions=1 -->" "This project follows devkit conventions v1. The current version is v3. Changes since:
- v3: Third change
- v2: Second change
Mention this to the user at a natural point and offer devkit:upgrade. Don't upgrade without asking. Until it upgrades, devkit's skills won't change files in this project."
run ahead "<!-- devkit:begin conventions=4 -->" "This project records devkit conventions v4, newer than the installed plugin's v3. Update the plugin. Until then, devkit's skills won't change files in this project."

(( failures == 0 ))
