#!/usr/bin/env bash
# SessionStart hook. When the project's AGENTS.md records a devkit conventions
# version other than the plugin's, says which side to update, since skills only
# change projects on the plugin's version (design-w6fv). Prints nothing for
# projects that don't use devkit.
set -euo pipefail

root="${CLAUDE_PLUGIN_ROOT:?CLAUDE_PLUGIN_ROOT is not set}"
agents="${CLAUDE_PROJECT_DIR:-$PWD}/AGENTS.md"

[[ -f "$agents" ]] || exit 0
have=$(sed -n 's/.*<!-- devkit:begin conventions=\([0-9][0-9]*\) -->.*/\1/p' "$agents" | head -n 1)
[[ -n "$have" ]] || exit 0
current=$(tr -d '[:space:]' < "$root/conventions/VERSION")

if (( have > current )); then
  echo "This project records devkit conventions v$have, newer than the installed plugin's v$current. Update the plugin. Until then, devkit's skills won't change files in this project."
elif (( have < current )); then
  echo "This project follows devkit conventions v$have. The current version is v$current. Changes since:"
  awk -v have="$have" '/^## v[0-9]+:/ {
    n = substr($2, 2, length($2) - 2) + 0
    if (n > have) print "- " substr($0, 4)
  }' "$root/conventions/CHANGELOG.md"
  echo "Mention this to the user at a natural point and offer devkit:upgrade. Don't upgrade without asking. Until it upgrades, devkit's skills won't change files in this project."
fi
