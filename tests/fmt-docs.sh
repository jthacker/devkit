#!/usr/bin/env bash
# Tests for plugin/conventions/templates/fmt-docs.sh against fake projects.
# New IDs are random, so each one is shown as <doc>-new<n>, numbered in the
# order it first appears.
# Expected docs are single-quoted, so backticks in them are literal.
# shellcheck disable=SC2016
set -euo pipefail

fmt="$(cd "$(dirname "$0")/.." && pwd)/plugin/conventions/templates/fmt-docs.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=user GIT_AUTHOR_EMAIL=user@example.com
export GIT_COMMITTER_NAME=user GIT_COMMITTER_EMAIL=user@example.com
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1

failures=0
same() { # name, expected, actual
  if [[ "$2" == "$3" ]]; then
    echo "ok   fmt $1"
  else
    echo "FAIL fmt $1"
    diff <(printf '%s\n' "$2") <(printf '%s\n' "$3") || true
    failures=$((failures + 1))
  fi
}
# Prints the files with each ID not in the known list replaced.
show() { # known IDs file, files...
  local known=$1
  shift
  for f in "$@"; do echo "== $f"; cat "$f"; done | awk -v known="$known" '
    BEGIN { while ((getline x < known) > 0) k[x] = 1 }
    { out = ""; line = $0
      while (match(line, /(prd|ux|design)-[0-9a-z][0-9a-z][0-9a-z][0-9a-z]/)) {
        id = substr(line, RSTART, RLENGTH)
        if (!(id in k)) {
          if (!(id in seen)) { kind = id; sub(/-.*/, "", kind); seen[id] = kind "-new" (++n[kind]) }
          id = seen[id]
        }
        out = out substr(line, 1, RSTART - 1) id; line = substr(line, RSTART + RLENGTH)
      }
      print out line }'
}
# Records the IDs a project already has, so show() leaves them alone.
known() { # dir
  grep -rhoE '(prd|ux|design)-[0-9a-z]{4}' "$1" --exclude-dir=.git > "$1.known" || true
}
repo() { # dir
  (cd "$1" && git init -q -b main && git add -A && git commit -q -m base)
}
run() { # dir, args...
  local dir=$1
  shift
  (cd "$dir" && "$fmt" "$@" 2>&1) || true
}

# A new project: plain headings, a requirement without an ID, bare IDs and
# links with the wrong text.
fresh="$tmp/fresh"
mkdir -p "$fresh/docs/plan" "$fresh/docs/analyses" "$fresh/src"
cat > "$fresh/docs/prd.md" <<'MD'
# Notes: Product requirements

## Requirements

### Sync <a id="prd-m2c7"></a>

1. **Edits reach every device.** An edit made offline appears within a
   minute of reconnecting.
5. **Conflicts never lose text.** <a id="prd-9tqe"></a> **Planned:** M4. Both are kept.

- **Bulleted.** Not a requirement.
MD
cat > "$fresh/docs/design.md" <<'MD'
# Notes: Design

1. [Overview](#)

## Overview

Every edit is kept on the device first, prd-m2c7.

## Sync <a id="design-r3wq"></a>

### Queue <a id="design-b6tn"></a>

### 7.4 Retries <a id="design-7kq3"></a>

Edits wait (see [the queue](#design-b6tn)). Examples such as `design-zz9z`
aren't checked, and neither are other repos, as in api:design-7kq3.

```markdown
## An example heading design-7kq3
```
MD
printf -- '- [ ] **M4.1** Retry failed syncs, design-7kq3 and prd-9tqe.\n' > "$fresh/docs/plan/M4.md"
printf 'Measured design-7kq3.\n' > "$fresh/docs/analyses/spike.md"
printf '// Give up after five attempts, design-7kq3.\n' > "$fresh/src/sync.go"
repo "$fresh"
known "$fresh"

same "check before" "docs/design.md:3: contents list is out of date; run just fmt
docs/design.md:5: heading has no ID; run just fmt
docs/design.md:7: cites prd-m2c7 without a link; run just fmt
docs/design.md:9: heading has no number; run just fmt
docs/design.md:11: heading has no number; run just fmt
docs/design.md:13: heading 7.4 is out of sequence; run just fmt
docs/design.md:15: link says the queue but should say Queue; run just fmt
docs/plan/M4.md:1: cites design-7kq3 without a link; run just fmt
docs/plan/M4.md:1: cites prd-9tqe without a link; run just fmt
docs/prd.md:3: heading has no ID; run just fmt
docs/prd.md:5: heading has no number; run just fmt
docs/prd.md:7: requirement has no ID; run just fmt
docs/prd.md:9: requirement 5 is out of sequence; run just fmt" "$(run "$fresh" --check)"

same "fmt" "" "$(run "$fresh")"
same "fresh result" '== docs/prd.md
# Notes: Product requirements

## 1. Requirements <a id="prd-new1"></a>

### 1.1 Sync <a id="prd-m2c7"></a>

1. **Edits reach every device.** <a id="prd-new2"></a> An edit made offline appears within a
   minute of reconnecting.
2. **Conflicts never lose text.** <a id="prd-9tqe"></a> **Planned:** M4. Both are kept.

- **Bulleted.** Not a requirement.
== docs/design.md
# Notes: Design

1. [Overview](#design-new1)
2. [Sync](#design-r3wq)

## 1. Overview <a id="design-new1"></a>

Every edit is kept on the device first, [PRD: Sync](prd.md#prd-m2c7).

## 2. Sync <a id="design-r3wq"></a>

### 2.1 Queue <a id="design-b6tn"></a>

### 2.2 Retries <a id="design-7kq3"></a>

Edits wait (see [Queue](#design-b6tn)). Examples such as `design-zz9z`
aren'"'"'t checked, and neither are other repos, as in api:design-7kq3.

```markdown
## An example heading design-7kq3
```
== docs/plan/M4.md
- [ ] **M4.1** Retry failed syncs, [Design: Retries](../design.md#design-7kq3) and [PRD: Conflicts never lose text](../prd.md#prd-9tqe).
== docs/analyses/spike.md
Measured design-7kq3.
== src/sync.go
// Give up after five attempts, design-7kq3.' "$(cd "$fresh" && show "$fresh.known" docs/prd.md docs/design.md docs/plan/M4.md docs/analyses/spike.md src/sync.go)"
same "check after" "" "$(run "$fresh" --check)"
same "fmt again" "" "$(cd "$fresh" && git add -A && git commit -q -m fmt && "$fmt" && git status --short)"

# Merge Queue into Retries, and move Sync to the UX doc. Links and code
# follow the surviving ID, except in files marked as examples.
moved="$tmp/moved"
cp -R "$fresh" "$moved"
(
  cd "$moved"
  awk '/^### 2.1 Queue/ { skip = 1; next } skip { skip--; next }
    /^### 2.2 Retries/ { sub(/<\/a>$/, "</a><a id=\"design-b6tn\"></a>") } { print }' docs/design.md > x
  mv x docs/design.md
  printf '// Queue, design-b6tn.\n' >> src/sync.go
  printf 'design-b6tn\n' > src/fixture.txt
  printf 'src/fixture.txt devkit-examples\n' > .gitattributes
  printf '# Notes: Experience\n\n## Sync <a id="design-r3wq"></a>\n\nSee design-7kq3.\n' > docs/ux.md
  awk '/^## 2. Sync/ { skip = 1; next } skip { skip--; next } { print }' docs/design.md > x
  mv x docs/design.md
)
same "check moved" "docs/design.md:3: contents list is out of date; run just fmt
docs/design.md:10: heading 2.2 is out of sequence; run just fmt
docs/design.md:12: links design-b6tn, which is now design-7kq3; run just fmt
docs/ux.md:3: section's main ID design-r3wq names another doc; give it a ux ID with just fmt
docs/ux.md:5: cites design-7kq3 without a link; run just fmt
src/sync.go:2: cites design-b6tn, which is now design-7kq3; run just fmt" "$(run "$moved" --check)"
run "$moved" > /dev/null
same "moved result" '== docs/design.md
# Notes: Design

1. [Overview](#design-new1)

## 1. Overview <a id="design-new1"></a>

Every edit is kept on the device first, [PRD: Sync](prd.md#prd-m2c7).

### 1.1 Retries <a id="design-7kq3"></a><a id="design-b6tn"></a>

Edits wait (see [Retries](#design-7kq3)). Examples such as `design-zz9z`
aren'"'"'t checked, and neither are other repos, as in api:design-7kq3.

```markdown
## An example heading design-7kq3
```
== docs/ux.md
# Notes: Experience

## 1. Sync <a id="ux-new1"></a><a id="design-r3wq"></a>

See [Design: Retries](design.md#design-7kq3).
== src/sync.go
// Give up after five attempts, design-7kq3.
// Queue, design-7kq3.
== src/fixture.txt
design-b6tn' "$(cd "$moved" && show "$fresh.known" docs/design.md docs/ux.md src/sync.go src/fixture.txt)"

# Citations of sections that don't exist, and an ID defined twice.
broken="$tmp/broken"
cp -R "$fresh" "$broken"
printf 'See [Gone](#design-zz98) and design-q9q9 and D3.\n### Again <a id="design-7kq3"></a>\n' >> "$broken/docs/design.md"
printf '// Gone, design-q9q9.\n' >> "$broken/src/sync.go"
want="docs/design.md:22: links design-zz98, which doesn't exist
docs/design.md:22: cites design-q9q9, which doesn't exist
docs/design.md:22: cites D3, which doesn't exist
docs/design.md:23: defines design-7kq3, which is already defined
src/sync.go:2: cites design-q9q9, which doesn't exist"
same "broken, check" "$(sed '4a\
docs/design.md:23: heading has no number; run just fmt
' <<< "$want")" "$(run "$broken" --check)"
same "broken, fmt" "$want" "$(run "$broken")"

# Hand-written IDs: a new one is kept, and one from the history is replaced
# with the links to it.
hand="$tmp/hand"
cp -R "$fresh" "$hand"
(
  cd "$hand"
  printf '### Gone <a id="design-p2x9"></a>\n' >> docs/design.md
  git commit -qam "Add a section"
  awk '!/Gone/' docs/design.md > x && mv x docs/design.md
  git commit -qam "Delete it"
  printf '### Mine <a id="design-h8fm"></a>\n\nSee design-p2x9.\n### Reused <a id="design-p2x9"></a>\n' >> docs/design.md
)
known "$hand"
same "hand-written" "docs/design.md:25: design-p2x9 is in the history, so the section is now design-new1" "$(run "$hand" | show "$hand.known" /dev/stdin | tail -n +2)"
same "hand-written result" '### 2.3 Mine <a id="design-h8fm"></a>

See [Reused](#design-new1).
### 2.4 Reused <a id="design-new1"></a>' "$(cd "$hand" && show "$hand.known" docs/design.md | tail -n 4)"

# A shallow clone can be checked but can't mint IDs.
shallow="$tmp/shallow"
git clone -q --depth 1 "file://$fresh" "$shallow" 2> /dev/null
printf '## Later\n' >> "$shallow/docs/design.md"
same "shallow check" "docs/design.md:3: contents list is out of date; run just fmt
docs/design.md:22: heading has no ID; run just fmt" "$(run "$shallow" --check)"
same "shallow fmt" "fmt-docs.sh: new sections need IDs, which must be checked against the whole history. This is a shallow clone, so fetch it with git fetch --unshallow." "$(run "$shallow")"

# Adopting v1 docs: a split design is joined, old numbers stay as anchors,
# R items become numbered requirements, and old IDs in code are listed.
v1="$tmp/v1"
mkdir -p "$v1/docs/design" "$v1/docs/plan" "$v1/src"
cat > "$v1/docs/prd.md" <<'MD'
# Old: Product requirements

## Goals

- **R1. Start in one request.** A repo with a PRD.
- **R2. Sync.** **Planned:** M2. Edits reach every device.

### R3. Area

- **R3.1** Users can export notes. They get a zip.
- **R3.2** **Planned:** M2. Users can import notes.
MD
cat > "$v1/docs/design.md" <<'MD'
# Old: Design

1. [Overview](#1-overview)
2. [Sync](design/2-sync.md)

## 1. Overview

Serves R1 and R3.2, as D2.1 says. See [sync](design/2-sync.md).
MD
cat > "$v1/docs/design/2-sync.md" <<'MD'
# 2. Sync

## 2.1 Retries

Retries R2 with backoff. The [plan](../plan.md) has more.
MD
printf '# Plan\n\nBuilds D2.1, in [Sync](design/2-sync.md).\n' > "$v1/docs/plan.md"
printf '// Retry with backoff, D2.1. R2D2 is a name.\n' > "$v1/src/sync.go"
repo "$v1"
known "$v1"
same "adopt" 'joined docs/design/2-sync.md into docs/design.md
These lines outside docs/ name old IDs. Rewrite each one that cites a section to the new ID:
src/sync.go:1: D2.1 is now design-new1' "$(run "$v1" --adopt | show "$v1.known" /dev/stdin | tail -n +2)"
same "adopt result" '== docs/prd.md
# Old: Product requirements

## 1. Goals <a id="prd-new1"></a>

1. **Start in one request.** <a id="prd-new2"></a><a id="R1"></a> A repo with a PRD.
2. **Sync.** <a id="prd-new3"></a><a id="R2"></a> **Planned:** M2. Edits reach every device.

### 1.1 Area <a id="prd-new4"></a><a id="R3"></a>

1. **Users can export notes.** <a id="prd-new5"></a><a id="R3.1"></a> They get a zip.
2. **Users can import notes.** <a id="prd-new6"></a><a id="R3.2"></a> **Planned:** M2.
== docs/design.md
# Old: Design

1. [Overview](#design-new1)
2. [Sync](#design-new2)

## 1. Overview <a id="design-new1"></a><a id="D1"></a>

Serves [PRD: Start in one request](prd.md#prd-new2) and [PRD: Users can import notes](prd.md#prd-new6), as [Retries](#design-new3) says. See [sync](design.md).

## 2. Sync <a id="design-new2"></a><a id="D2"></a>

### 2.1 Retries <a id="design-new3"></a><a id="D2.1"></a>

Retries [PRD: Sync](prd.md#prd-new3) with backoff. The [plan](plan.md) has more.
== docs/plan.md
# Plan

Builds [Design: Retries](design.md#design-new3), in [Sync](design.md).' "$(cd "$v1" && show "$v1.known" docs/prd.md docs/design.md docs/plan.md)"
same "adopt leaves no old design dir" "" "$(ls "$v1/docs/design" 2> /dev/null || true)"

# A v1 design split into one file per section, named by section number,
# with two files the contents list doesn't link, which follow in number
# order.
sections="$tmp/sections"
mkdir -p "$sections/docs/design"
cat > "$sections/docs/design.md" <<'MD'
# Old: Design

1. [Retries](design/2.1-retries.md)
2. [Queue](design/2.2-queue.md)
3. [Alternatives](design/3-alternatives.md)
MD
printf '# 2.1 Retries\n\nRetries run in D2.10.\n' > "$sections/docs/design/2.1-retries.md"
printf '# 2.2 Queue\n\nSee [retries](2.1-retries.md).\n' > "$sections/docs/design/2.2-queue.md"
printf '# 2.10 Later\n\nLast part.\n' > "$sections/docs/design/2.10-later.md"
printf '# 2.9 Soon\n\nNext part.\n' > "$sections/docs/design/2.9-soon.md"
printf '# 3. Alternatives\n\nNone.\n' > "$sections/docs/design/3-alternatives.md"
printf '# Plan\n\nBuilds [queue](design/2.2-queue.md).\n' > "$sections/docs/plan.md"
repo "$sections"
known "$sections"
run "$sections" --adopt > /dev/null
same "adopt joins section files" '== docs/design.md
# Old: Design

1. [Retries](#design-new1)
2. [Queue](#design-new2)
3. [Alternatives](#design-new3)
4. [Soon](#design-new4)
5. [Later](#design-new5)

## 1. Retries <a id="design-new1"></a><a id="D2.1"></a>

Retries run in [Later](#design-new5).

## 2. Queue <a id="design-new2"></a><a id="D2.2"></a>

See [retries](design.md).

## 3. Alternatives <a id="design-new3"></a><a id="D3"></a>

None.

## 4. Soon <a id="design-new4"></a><a id="D2.9"></a>

Next part.

## 5. Later <a id="design-new5"></a><a id="D2.10"></a>

Last part.
== docs/plan.md
# Plan

Builds [queue](design.md).' "$(cd "$sections" && show "$sections.known" docs/design.md docs/plan.md)"
same "adopt leaves no section files" "" "$(ls "$sections/docs/design" 2> /dev/null || true)"

# A contents list whose items include unlinked parents with links nested
# under them is replaced whole. A list before it without links is kept.
nested="$tmp/nested"
mkdir -p "$nested/docs"
cat > "$nested/docs/design.md" <<'MD'
# Nested: Design

- Kept, since it links nothing.

1. Overview
   - [Goals](#design-g2a1)
2. [Sync](#design-r3wq)
3. Later
   1. [Ideas](#design-1d3a)

## 1. Overview <a id="design-a1b2"></a>

### 1.1 Goals <a id="design-g2a1"></a>

## 2. Sync <a id="design-r3wq"></a>

## 3. Later <a id="design-c3d4"></a>

### 3.1 Ideas <a id="design-1d3a"></a>
MD
repo "$nested"
same "check nested contents" "docs/design.md:5: contents list is out of date; run just fmt" "$(run "$nested" --check)"
run "$nested" > /dev/null
same "nested contents replaced" '# Nested: Design

- Kept, since it links nothing.

1. [Overview](#design-a1b2)
2. [Sync](#design-r3wq)
3. [Later](#design-c3d4)

## 1. Overview <a id="design-a1b2"></a>

### 1.1 Goals <a id="design-g2a1"></a>

## 2. Sync <a id="design-r3wq"></a>

## 3. Later <a id="design-c3d4"></a>

### 3.1 Ideas <a id="design-1d3a"></a>' "$(cat "$nested/docs/design.md")"

(( failures == 0 ))
