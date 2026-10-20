#!/usr/bin/env bash
# Checks a project's docs against the devkit conventions. Managed by devkit:
# only devkit's upgrade replaces this file.
# Usage: lint-docs.sh [project-root [base]]
# IDs defined at the base commit must still be defined or aliased. The base
# defaults to the upstream branch, or HEAD without one.
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

# Prints file:line:ID:target for each ID a doc defines, outside code blocks.
# Numbered headings define D or U sections, and a PRD defines R IDs in
# headings or bold (section 2). An **Also:** line makes each ID on it an
# alias of the section above, printed with that section as its target
# (section 18). Live IDs have no target.
defs() { # prefix, files...
  local prefix=$1; shift
  [[ $# -gt 0 ]] || return 0
  awk -v kind="$prefix" 'FNR == 1 { code = 0; current = "" }
    /^[[:space:]]*```/ { code = !code; next }
    code { next }
    { line = $0 }
    kind == "R" {
      while (match(line, /(^#+ |\*\*)R[0-9]+(\.[0-9]+)*/)) {
        id = substr(line, RSTART, RLENGTH); sub(/^[#* ]+/, "", id)
        print FILENAME ":" FNR ":" id ":"; current = id
        line = substr(line, RSTART + RLENGTH)
      }
    }
    kind != "R" && match(line, /^#+ [0-9]+(\.[0-9]+)*/) {
      id = substr(line, RSTART, RLENGTH); sub(/^#+ /, "", id)
      current = kind id
      print FILENAME ":" FNR ":" current ":"
    }
    { gsub(/`[^`]*`/, "", line) }
    match(line, /\*\*Also:\*\*/) {
      line = " " substr(line, RSTART + RLENGTH)
      while (match(line, "[^A-Za-z0-9_]" kind "[0-9]+([.][0-9]+)*")) {
        print FILENAME ":" FNR ":" substr(line, RSTART + 1, RLENGTH - 1) ":" current
        line = substr(line, RSTART + RLENGTH)
      }
    }' "$@"
}

# Prints every ID the docs in the current directory define, live or alias.
all_ids() {
  defs D $(existing docs/design.md docs/design/*.md)
  defs U $(existing docs/ux.md docs/ux/*.md)
  defs R $(existing docs/prd.md docs/prd/*.md)
}

# R, U and D IDs, and their aliases, are defined once each (section 2).
all_defs=$(all_ids || true)
while IFS=: read -r f n id _; do
  fail "$f:$n: defines $id, which is already defined"
done < <(awk -F: 'seen[$3]++' <<< "$all_defs")
live=$(awk -F: '$3 != "" && $4 == "" { print $3 }' <<< "$all_defs" | sort -u)
aliases=$(awk -F: '$4 != "" { print $3 " " $4 }' <<< "$all_defs")

# Prints the current ID an alias stands for. An alias covers its subsections,
# so with D4.3 an alias of D9, D4.3.2 is D9.2 (section 18).
resolve() { # ID
  local head=$1 tail='' target
  while :; do
    target=$(awk -v a="$head" '$1 == a { print $2 }' <<< "$aliases")
    [[ -n "$target" ]] && { echo "$target$tail"; return 0; }
    [[ "$head" == *.* ]] || return 1
    tail=".${head##*.}$tail"; head=${head%.*}
  done
}

# Citations name current sections (section 2). IDs in backticks are
# examples, and qualified IDs such as api:D4.2 name another repo, so neither
# is checked. Analyses are never rewritten, so they aren't checked either.
cited=$(printf '%s\n' $docs | grep -v '^docs/analyses/' | while read -r f; do
  awk 'FNR == 1 { code = 0 }
    /^[[:space:]]*```/ { code = !code; next }
    code { next }
    /\*\*Also:\*\*/ { next }
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
  grep -qxF "$id" <<< "$live" && continue
  if now=$(resolve "$id"); then
    fail "$f:$n: cites $id, which is now $now"
  else
    fail "$f:$n: cites $id, which doesn't exist"
  fi
done <<< "$cited"

# IDs never leave the docs (section 18). Each one defined at the base,
# live or alias, is still live, or is covered by an alias.
base=${2:-}
if [[ -z "$base" ]] && git rev-parse --verify --quiet HEAD > /dev/null 2>&1; then
  base=HEAD
  git rev-parse --verify --quiet '@{upstream}' > /dev/null 2>&1 \
    && base=$(git merge-base HEAD '@{upstream}')
fi
if [[ -n "$base" ]]; then
  snapshot=$(mktemp -d)
  trap 'rm -rf "$snapshot"' EXIT
  git archive "$base" docs 2>/dev/null | tar -x -C "$snapshot" 2>/dev/null || true
  base_defs=$(cd "$snapshot" && { all_ids || true; })
  while IFS=: read -r f _ id _; do
    [[ -n "$id" ]] || continue
    grep -qxF "$id" <<< "$live" && continue
    resolve "$id" > /dev/null && continue
    fail "$f: $id is gone; list it under **Also:** where its text went"
  done <<< "$base_defs"
fi

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
