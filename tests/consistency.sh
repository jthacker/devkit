#!/usr/bin/env bash
# Checks that the conventions' version, changelog, skills and templates agree.
set -euo pipefail

cd "$(dirname "$0")/../plugin"
failures=0
fail() { echo "FAIL $*"; failures=$((failures + 1)); }

version=$(tr -d '[:space:]' < conventions/VERSION)
latest=$(sed -n 's/^## v\([0-9][0-9]*\):.*/\1/p' conventions/CHANGELOG.md | head -n 1)
[[ "$version" == "$latest" ]] || fail "VERSION is $version but the newest changelog entry is v$latest"
# The plugin version's major is the conventions version, so a convention
# change always moves it and cached installs update (design-chm4).
plugin_version=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' .claude-plugin/plugin.json)
[[ "$plugin_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "plugin version $plugin_version isn't semver"
[[ "${plugin_version%%.*}" == "$version" ]] || fail "plugin version is $plugin_version but VERSION is $version"

grep -q '<!-- devkit:begin conventions={{VERSION}} -->' conventions/templates/agents-block.md \
  || fail "agents-block.md lacks the begin marker"
grep -q '<!-- devkit:end -->' conventions/templates/agents-block.md \
  || fail "agents-block.md lacks the end marker"

for skill in skills/*/SKILL.md; do
  name=$(basename "$(dirname "$skill")")
  grep -q "^name: $name$" "$skill" || fail "$skill: name doesn't match its directory"
  grep -q '^description: ' "$skill" || fail "$skill: no description"
  # Skills that only make sense in a devkit project say so first, so they
  # aren't offered elsewhere (design-e8ng, prd-4svd).
  case $name in
    new-project|upgrade) ;;
    *) grep -q '^description: In a project that uses devkit, ' "$skill" \
         || fail "$skill: description doesn't start with 'In a project that uses devkit'" ;;
  esac
  grep -q "devkit:$name\`" ../docs/user/skills.md || fail "docs/user/skills.md doesn't list devkit:$name"
  # Every path a skill names under the plugin root must exist.
  # shellcheck disable=SC2016 # the variable is matched literally
  while read -r path; do
    [[ -e "$path" ]] || fail "$skill names $path, which doesn't exist"
  done < <(grep -o '\${CLAUDE_PLUGIN_ROOT}/[A-Za-z0-9_./-]*' "$skill" | sed 's|^\${CLAUDE_PLUGIN_ROOT}/||; s|[.]$||' | sort -u)
  # Every other devkit skill a skill names must exist.
  while read -r ref; do
    [[ "$ref" == begin || "$ref" == end ]] && continue
    [[ -d "skills/$ref" ]] || fail "$skill names devkit:$ref, which doesn't exist"
  done < <(grep -o 'devkit:[a-z-]*' "$skill" | sed 's/devkit://' | sort -u)
done

if grep -rn '—' conventions skills; then fail "em dashes above"; fi
# Agents find sections by grepping for headings, so an example heading in a
# fence reads as a real one. Templates are skipped, since their docs hold
# real headings.
fenced=$(find conventions/CONVENTIONS.md conventions/CHANGELOG.md skills -name '*.md' -exec awk '
  FNR == 1 { fence = 0 }
  /^[ \t]*(```|~~~)/ { fence = !fence; next }
  fence && /^#/ { print FILENAME ":" FNR ": " $0 }' {} +)
[[ -z "$fenced" ]] || fail "example headings in fences, which read as real ones; write them inline:
$fenced"

(( failures == 0 )) && echo "ok   consistency"
(( failures == 0 ))
