#!/usr/bin/env bash
# Checks a project's docs against the devkit conventions. Managed by devkit:
# only devkit's upgrade replaces this file. Usage: lint-docs.sh [project-root]
# Paths never contain spaces (CONVENTIONS.md section 7), so lists of paths
# are split on whitespace.
# shellcheck disable=SC2086,SC2046
set -euo pipefail

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

# Docs past 600 lines (section 5).
for f in $docs; do
  n=$(wc -l < "$f" | tr -d ' ')
  (( n <= 600 )) || fail "$f: $n lines, past 600; split it by chapter"
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

# Prints file:line:ID for each section a doc defines, outside code blocks.
# Numbered headings define D or U sections, and a PRD defines R IDs in
# headings or bold (section 2).
defs() { # prefix, files...
  local prefix=$1; shift
  [[ $# -gt 0 ]] || return 0
  awk -v kind="$prefix" 'FNR == 1 { code = 0 }
    /^[[:space:]]*```/ { code = !code; next }
    code { next }
    kind == "R" {
      line = $0
      while (match(line, /(^#+ |\*\*)R[0-9]+(\.[0-9]+)*/)) {
        id = substr(line, RSTART, RLENGTH); sub(/^[#* ]+/, "", id)
        print FILENAME ":" FNR ":" id
        line = substr(line, RSTART + RLENGTH)
      }
      next
    }
    match($0, /^#+ [0-9]+(\.[0-9]+)*/) {
      id = substr($0, RSTART, RLENGTH); sub(/^#+ /, "", id)
      print FILENAME ":" FNR ":" kind id
    }' "$@"
}

# R, U and D IDs are defined once each (section 2).
all_defs=$( {
  defs D $(existing docs/design.md docs/design/*.md)
  defs U $(existing docs/ux.md docs/ux/*.md)
  defs R $(existing docs/prd.md docs/prd/*.md)
} || true)
while IFS=: read -r f n id; do
  fail "$f:$n: defines $id, which is already defined"
done < <(awk -F: 'seen[$3]++' <<< "$all_defs")
defined=$(cut -d: -f3 <<< "$all_defs" | sort -u)

# Citations name sections that exist (section 2). IDs in backticks are
# examples, and qualified IDs such as api:D4.2 name another repo, so neither
# is checked. Analyses are never rewritten, so they aren't checked either.
cited=$(printf '%s\n' $docs | grep -v '^docs/analyses/' | while read -r f; do
  awk 'FNR == 1 { code = 0 }
    /^[[:space:]]*```/ { code = !code; next }
    code { next }
    { line = " " $0; gsub(/`[^`]*`/, "", line)
      while (match(line, /[^A-Za-z0-9_:][DRU][0-9]+(\.[0-9]+)*/)) {
        id = substr(line, RSTART + 1, RLENGTH - 1)
        rest = substr(line, RSTART + RLENGTH)
        if (rest !~ /^[A-Za-z0-9_]/) print FILENAME ":" FNR ":" id
        line = rest
      } }' "$f"
done || true)
while IFS=: read -r f n id; do
  [[ -n "$id" ]] || continue
  grep -qxF "$id" <<< "$defined" || fail "$f:$n: cites $id, which doesn't exist"
done <<< "$cited"

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
