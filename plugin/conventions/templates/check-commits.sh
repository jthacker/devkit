#!/usr/bin/env bash
# Checks that commits carry the trailers the devkit conventions ask for
# (CONVENTIONS.md section 17). Managed by devkit: only devkit's upgrade
# replaces this file. Usage: check-commits.sh [range]
# With no range it checks the commits not yet on the upstream branch. Merge
# commits, and commits made before this script was added, are skipped.
set -euo pipefail

if [[ $# -gt 0 ]]; then
  range=$1
elif git rev-parse --verify --quiet '@{upstream}' > /dev/null; then
  range='@{upstream}..HEAD'
else
  echo "ok   commits (no upstream)"
  exit 0
fi

self=$(git ls-files --full-name -- "$0")
added=
[[ -z "$self" ]] || added=$(git log --diff-filter=A --format=%H -- "$self" | tail -n 1)
if [[ -z "$added" ]]; then
  echo "ok   commits (check not committed yet)"
  exit 0
fi
older=()
git rev-parse --verify --quiet "$added^" > /dev/null && older=("^$added^")

failures=0
fail() { echo "$1"; failures=$((failures + 1)); }

while read -r commit; do
  where="$(git log -1 --format='%h %s' "$commit")"
  values=$(git log -1 --format='%(trailers:key=Change,valueonly,separator=%x20)' "$commit")
  note=$(git log -1 --format='%(trailers:key=Changelog,valueonly)' "$commit")
  read -ra kinds <<< "$values"
  if (( ${#kinds[@]} == 0 )); then
    fail "$where: no Change trailer"
    continue
  fi
  if (( ${#kinds[@]} > 1 )); then
    fail "$where: more than one Change value; split the commit"
    continue
  fi
  case ${kinds[0]} in
    added|changed|deprecated|removed|fixed|security)
      [[ -n "$note" ]] || fail "$where: Change ${kinds[0]} needs a Changelog trailer" ;;
    ops) ;;
    docs|internal)
      [[ -z "$note" ]] || fail "$where: Change ${kinds[0]} takes no Changelog trailer" ;;
    *) fail "$where: unknown Change value ${kinds[0]}" ;;
  esac
done < <(git rev-list --no-merges "$range" "${older[@]}")

(( failures == 0 )) && echo "ok   commits"
(( failures == 0 ))
