#!/usr/bin/env bash
# Tests for plugin/conventions/templates/check-commits.sh against a temporary repo.
set -euo pipefail

source="$(cd "$(dirname "$0")/.." && pwd)/plugin/conventions/templates/check-commits.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=user GIT_AUTHOR_EMAIL=user@example.com
export GIT_COMMITTER_NAME=user GIT_COMMITTER_EMAIL=user@example.com
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1

failures=0
expect() { # name, expected output, args...
  local name=$1 want=$2 out
  shift 2
  out=$(.devkit/check-commits.sh "$@" 2>&1 || true)
  if [[ "$out" == "$want" ]]; then
    echo "ok   commits $name"
  else
    echo "FAIL commits $name"
    diff <(printf '%s\n' "$want") <(printf '%s\n' "$out") || true
    failures=$((failures + 1))
  fi
}
commit() { # subject, trailer lines...
  local msg=$1
  shift
  (( $# == 0 )) || msg+=$'\n\n'$(printf '%s\n' "$@")
  git commit -q --allow-empty -m "$msg"
}

cd "$tmp"
git init -q -b main
commit "Before the check"
mkdir .devkit
cp "$source" .devkit/check-commits.sh

expect uncommitted "ok   commits (check not committed yet)" HEAD

git add .devkit
commit "Add the commit check" "Change: internal"
commit "Retry failed syncs, D8.3" "Change: fixed" "Changelog: Edits made offline are no longer lost."
commit "Raise the pool size" "Change: ops"
git checkout -q -b side
commit "Note the pool size" "Change: docs"
git checkout -q main
git merge -q --no-ff -m "Merge side" side
expect good "ok   commits" HEAD
expect "no upstream" "ok   commits (no upstream)"

git branch -q base
git branch -q --set-upstream-to=base
commit "Untyped"
commit "Two kinds" "Change: fixed" "Change: deprecated" "Changelog: A note."
commit "Unknown kind" "Change: feature"
commit "Fix without a note" "Change: fixed"
commit "Refactor with a note" "Change: internal" "Changelog: Nobody sees this."
log() { git log -1 --format='%h %s' "HEAD~$1"; }
expect bad "$(log 0): Change internal takes no Changelog trailer
$(log 1): Change fixed needs a Changelog trailer
$(log 2): unknown Change value feature
$(log 3): more than one Change value; split the commit
$(log 4): no Change trailer"
expect range "$(log 0): Change internal takes no Changelog trailer" HEAD~1..HEAD

(( failures == 0 ))
