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

# Relative links that point nowhere, and anchors in a Markdown file that it
# doesn't define. fmt-docs.sh checks links to section IDs in the docs it
# rewrites, so those are left to it.
idlike='^((prd|ux|design)-[0-9a-z]{4}|[DRU][0-9]+(\.[0-9]+)*)$'
anchored=""
while IFS=: read -r f n target; do
  case "$target" in http:* | https:* | mailto:* | *'{{'*) continue ;; esac
  path="${target%%#*}"
  dest="$(dirname "$f")/$path"; [[ -n "$path" ]] || dest=$f
  if [[ ! -e "$dest" ]]; then fail "$f:$n: broken link to $target"; continue; fi
  [[ "$target" == *'#'* && -f "$dest" && "$dest" == *.md ]] || continue
  frag="${target#*#}"
  case "$f" in docs/analyses/*) ;; docs/*) [[ "$frag" =~ $idlike ]] && continue ;; esac
  anchored="$anchored$f"$'\t'"$n"$'\t'"$target"$'\t'"$dest"$'\t'"$frag"$'\n'
done < <(links $files)

# Of the links above, those whose anchor isn't in their file. A file's
# anchors are its HTML ids and names, and the slugs GitHub gives its
# headings, with and without the space an anchor tag leaves at the end.
while IFS= read -r problem; do
  [[ -n "$problem" ]] && fail "$problem"
done < <(printf '%s' "$anchored" | awk -F '\t' '
  function slug(s,   t) {
    while (match(s, /\[[^]]*\]\([^)]*\)/)) {
      t = substr(s, RSTART + 1, RLENGTH); sub(/\]\(.*/, "", t)
      s = substr(s, 1, RSTART - 1) t substr(s, RSTART + RLENGTH)
    }
    gsub(/<[^>]*>/, "", s); s = tolower(s)
    gsub(/-/, "\001", s); gsub(/_/, "\002", s); gsub(/[[:punct:]]/, "", s)
    gsub(/\001/, "-", s); gsub(/\002/, "_", s); gsub(/ /, "-", s)
    return s
  }
  function add(file, a) { if (a != "") has[file, a] = 1 }
  function heading(file, s,   base, k) {
    sub(/^#+[ \t]*/, "", s); sub(/[ \t]+#+[ \t]*$/, "", s); sub(/[ \t]+$/, "", s)
    base = slug(s); k = seen[file, base]++
    add(file, k ? base "-" k : base)
    sub(/[ \t]*(<[^>]*>[ \t]*)+$/, "", s)
    add(file, slug(s))
  }
  function load(file,   x, fence, t, a) {
    loaded[file] = 1; fence = 0
    while ((getline x < file) > 0) {
      if (x ~ /^[ \t]*(```|~~~)/) { fence = !fence; continue }
      if (fence) continue
      if (x ~ /^#+[ \t]/) heading(file, x)
      t = x; gsub(/`[^`]*`/, "", t)
      while (match(t, /(id|name)="[^"]*"/)) {
        a = substr(t, RSTART, RLENGTH); sub(/^[a-z]*="/, "", a); sub(/"$/, "", a)
        add(file, a); t = substr(t, RSTART + RLENGTH)
      }
    }
    close(file)
  }
  { if (!($4 in loaded)) load($4)
    if (!(($4, $5) in has)) print $1 ":" $2 ": broken link to " $3 }')

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

# Inside a planned section, every heading and requirement carries its own
# marker, so a reader who lands on one by its ID sees it isn't built.
while IFS= read -r problem; do
  [[ -n "$problem" ]] && fail "$problem"
done < <(awk '
  function inside(lvl,   k) { for (k = 1; k < lvl; k++) if (planned[k]) return 1; return 0 }
  function resolve(mark) {
    if (!pend) return
    pend = 0; planned[plvl] = mark
    if (!mark && inside(plvl)) print pfile ":" pline ": heading inside a planned section has no planned marker"
  }
  FNR == 1 { resolve(0); fence = 0; split("", planned) }
  /^[ \t]*(```|~~~)/ { resolve(0); fence = !fence; next }
  fence || /^[ \t]*$/ { next }
  /^#+[ \t]/ {
    resolve(0); match($0, /^#+/)
    for (k = RLENGTH; k <= 9; k++) planned[k] = 0
    pend = 1; plvl = RLENGTH; pline = FNR; pfile = FILENAME; next
  }
  { resolve($0 ~ /^\*\*Planned:\*\* M[0-9]+/) }
  FILENAME ~ /prd\.md$/ && /^[0-9]+\. \*\*/ && inside(10) && !/\*\*Planned:\*\* M[0-9]+/ {
    print FILENAME ":" FNR ": requirement inside a planned section has no planned marker"
  }
  END { resolve(0) }' $(existing docs/prd.md docs/ux.md docs/design.md) /dev/null)

(( failures == 0 )) && echo "ok   docs"
(( failures == 0 ))
