#!/usr/bin/env bash
# Tests for plugin/conventions/templates/lint-docs.sh against fake projects.
set -euo pipefail

lint="$(cd "$(dirname "$0")/.." && pwd)/plugin/conventions/templates/lint-docs.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

failures=0
expect() { # name, project dir, expected output
  local out
  out=$("$lint" "$2" || true)
  if [[ "$out" == "$3" ]]; then
    echo "ok   lint $1"
  else
    echo "FAIL lint $1"
    diff <(printf '%s\n' "$3") <(printf '%s\n' "$out") || true
    failures=$((failures + 1))
  fi
}

good="$tmp/good"
mkdir -p "$good/docs/user"
cat > "$good/docs/README.md" <<'MD'
| [prd.md](prd.md) | [design.md](design.md#1-overview) | [Guide](user/README.md) |
MD
cat > "$good/docs/prd.md" <<'MD'
### R1. Area
- **R1.1** A requirement.
MD
cat > "$good/docs/design.md" <<'MD'
## 1. Overview
Serves R1.1. Examples such as `D9.9` aren't checked.
### 1.2 Detail
See D1.2 and the D4 chapter. [Web](https://example.com)
```
D7 in a code block isn't checked.
```
MD
mkdir -p "$good/docs/design"
printf '# 4. Chapter\n' > "$good/docs/design/4-chapter.md"
printf '# Guide\n' > "$good/docs/user/README.md"
expect good "$good" "ok   docs"

bad="$tmp/bad"
mkdir -p "$bad/docs/proposals"
printf '[gone](missing.md)\n' > "$bad/README.md"
printf '[prd.md](prd.md)\n' > "$bad/docs/README.md"
printf '### R1. Area\nCovered in D3 \xe2\x80\x94 later.\n' > "$bad/docs/prd.md"
printf '# Proposal\n' > "$bad/docs/proposals/x.md"
for _ in $(seq 601); do echo; done > "$bad/docs/long.md"
expect bad "$bad" "docs/prd.md:2: em dash
docs/long.md: 601 lines, past 600; split it by chapter
README.md:1: broken link to missing.md
docs/README.md: doesn't link long.md
docs/README.md: doesn't link proposals/x.md
docs/prd.md:2: cites D3, which doesn't exist"

# Planned sections, UX IDs, milestone files and qualified citations.
lifecycle="$tmp/lifecycle"
mkdir -p "$lifecycle/docs/plan" "$lifecycle/docs/user"
cat > "$lifecycle/docs/README.md" <<'MD'
[prd.md](prd.md) [ux.md](ux.md) [design.md](design.md) [plan.md](plan.md)
MD
cat > "$lifecycle/docs/prd.md" <<'MD'
- **R1. Sync.** **Planned:** M2. Edits reach every device.
MD
cat > "$lifecycle/docs/ux.md" <<'MD'
## 3. Flows
### 3.1 Sign in
Serves R1. The API is described in api:D4.2 and api:U1.
MD
cat > "$lifecycle/docs/design.md" <<'MD'
## 1. Overview
**Planned:** M1
Follows U3.1.
```markdown
## 1. An example heading isn't a definition
**Planned:** M9
```
`**Planned:** M8` in backticks is an example.
MD
printf '# Plan

## M1. First

[M2](plan/M2.md)
' > "$lifecycle/docs/plan.md"
printf '# M2. Second
' > "$lifecycle/docs/plan/M2.md"
printf '# Guide
' > "$lifecycle/docs/user/README.md"
expect lifecycle "$lifecycle" "ok   docs"

drift="$tmp/drift"
cp -R "$lifecycle" "$drift"
printf '## 3. Again
See U5.
' >> "$drift/docs/ux.md"
printf '**Planned:** M7
' >> "$drift/docs/design.md"
printf '**Planned:** M1
' >> "$drift/docs/user/README.md"
printf '# M3. Third
' > "$drift/docs/plan/M3.md"
expect drift "$drift" "docs/plan.md: doesn't link plan/M3.md
docs/ux.md:4: defines U3, which is already defined
docs/ux.md:5: cites U5, which doesn't exist
docs/design.md:9: planned for M7, which isn't in the plan
docs/user/README.md:2: planned marker in user docs"

expect empty "$tmp" "ok   docs (none found)"

(( failures == 0 ))
