#!/usr/bin/env bash
# Checks a project's docs against the devkit conventions. Managed by devkit:
# only devkit's upgrade replaces this file.
# Usage: lint-docs.sh [project-root]
# Section IDs and citations are checked by fmt-docs.sh --check, next to it.
# Paths never contain spaces (CONVENTIONS.md section 7), so lists of paths
# are split on whitespace.
# shellcheck disable=SC2086,SC2046
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
cd "${1:-.}"
failures=0
fail() { echo "$1"; failures=$((failures + 1)); }

docs=$( { find docs -name '*.md' -type f 2>/dev/null || true; } | sort)
files=$(printf '%s\n' README.md AGENTS.md $docs | while read -r f; do [[ -f "$f" ]] && echo "$f"; done || true)
[[ -n "$files" ]] || { echo "ok   docs (none found)"; exit 0; }

# Em dashes (CONVENTIONS.md section 4).
while IFS= read -r hit; do
  fail "$hit: em dash"
done < <(grep -n $'\xe2\x80\x94' $files /dev/null | cut -d: -f1,2 || true)

# Docs past 600 lines get a warning (section 5).
for f in $docs; do
  n=$(wc -l < "$f" | tr -d ' ')
  (( n <= 600 )) || echo "warn $f: $n lines, past 600; move what belongs elsewhere"
done

# Prints file:line:target for each Markdown link outside code blocks.
links() {
  awk 'FNR == 1 { code = 0 }
    /^[[:space:]]*```/ { code = !code; next }
    code { next }
    { line = $0; gsub(/`[^`]*`/, "", line)
      while (match(line, /\]\([^) ]+/)) {
        print FILENAME ":" FNR ":" substr(line, RSTART + 2, RLENGTH - 2)
        line = substr(line, RSTART + RLENGTH)
      } }' "$@"
}

# Relative links that point nowhere.
while IFS=: read -r f n target; do
  case "$target" in http:* | https:* | mailto:* | '#'* | *'{{'*) continue ;; esac
  path="${target%%#*}"
  [[ -e "$(dirname "$f")/$path" ]] || fail "$f:$n: broken link to $target"
done < <(links $files)

# Every doc is listed in its index (section 1).
indexed() { # index, doc path relative to the index
  [[ -f "$1" ]] && grep -qF -e "]($2)" -e "]($2#" "$1" && return 0
  fail "$1: doesn't link $2"
}
for f in docs/*.md docs/proposals/*.md docs/analyses/*.md; do
  [[ -f "$f" && "$f" != docs/README.md ]] && indexed docs/README.md "${f#docs/}"
done
for f in docs/plan/*.md; do
  [[ -f "$f" ]] && indexed docs/plan.md "${f#docs/}"
done
for f in docs/user/*.md; do
  [[ -f "$f" && "$f" != docs/user/README.md ]] && indexed docs/user/README.md "${f#docs/user/}"
done

# Prints the files that exist among the arguments.
existing() { for f in "$@"; do [[ -f "$f" ]] && echo "$f"; done; return 0; }

# Sections are numbered and have IDs, links and citations in docs and code
# name sections that exist, and no ID is defined twice (section 2).
while IFS= read -r problem; do
  [[ -n "$problem" ]] && fail "$problem"
done < <("$here/fmt-docs.sh" --check . || true)

# Planned markers name a milestone in the plan, and never appear in user
# docs, which describe only what is built (section 3.6).
milestones=$(cat $(existing docs/plan.md docs/plan/*.md) /dev/null | sed -nE 's/^#+ (M[0-9]+)\..*/\1/p')
planned=$(printf '%s\n' $docs | grep -v '^docs/analyses/' | while read -r f; do
  awk 'FNR == 1 { code = 0 }
    /^[[:space:]]*```/ { code = !code; next }
    code { next }
    { line = $0; gsub(/`[^`]*`/, "", line)
      if (match(line, /\*\*Planned:\*\* M[0-9]+/)) {
        m = substr(line, RSTART, RLENGTH); sub(/.* /, "", m)
        print FILENAME ":" FNR ":" m
      } }' "$f"
done || true)
while IFS=: read -r f n m; do
  [[ -n "$m" ]] || continue
  case "$f" in
    docs/user/*) fail "$f:$n: planned marker in user docs" ;;
    *) grep -qxF "$m" <<< "$milestones" || fail "$f:$n: planned for $m, which isn't in the plan" ;;
  esac
done <<< "$planned"

(( failures == 0 )) && echo "ok   docs"
(( failures == 0 ))
