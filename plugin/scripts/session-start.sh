#!/usr/bin/env bash
# SessionStart hook. When the project's AGENTS.md records an older devkit
# conventions version than the plugin's, prints what changed since, for the
# agent to pass on. Prints nothing for projects that don't use devkit.
set -euo pipefail

root="${CLAUDE_PLUGIN_ROOT:?CLAUDE_PLUGIN_ROOT is not set}"
agents="${CLAUDE_PROJECT_DIR:-$PWD}/AGENTS.md"

[[ -f "$agents" ]] || exit 0
have=$(sed -n 's/.*<!-- devkit:begin conventions=\([0-9][0-9]*\) -->.*/\1/p' "$agents" | head -n 1)
[[ -n "$have" ]] || exit 0
current=$(tr -d '[:space:]' < "$root/conventions/VERSION")

if (( have > current )); then
  echo "This project records devkit conventions v$have, newer than the installed plugin's v$current. The plugin may be out of date."
elif (( have < current )); then
  echo "This project follows devkit conventions v$have. The current version is v$current. Changes since:"
  awk -v have="$have" '/^## v[0-9]+:/ {
    n = substr($2, 2, length($2) - 2) + 0
    if (n > have) print "- " substr($0, 4)
  }' "$root/conventions/CHANGELOG.md"
  echo "Mention this to the user at a natural point and offer devkit:upgrade. Don't upgrade without asking."
fi
