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
| [prd.md](prd.md) | [design.md](design.md) | [Guide](user/README.md) |
MD
cat > "$good/docs/prd.md" <<'MD'
## 1. Area <a id="prd-m2c7"></a>
1. **A requirement.** <a id="prd-4hz8"></a> It says what.
MD
cat > "$good/docs/design.md" <<'MD'
## 1. Overview <a id="design-q2m8"></a>
Serves [PRD: A requirement](prd.md#prd-4hz8). Examples such as `design-zz9z` aren't checked.
### 1.1 Detail <a id="design-7kq3"></a>
See [Overview](#design-q2m8). [Web](https://example.com)
```
design-zz9z in a code block isn't checked.
```
MD
printf '# Guide\n' > "$good/docs/user/README.md"
expect good "$good" "ok   docs"

bad="$tmp/bad"
mkdir -p "$bad/docs/proposals"
printf '[gone](missing.md)\n' > "$bad/README.md"
printf '[prd.md](prd.md)\n' > "$bad/docs/README.md"
printf '## 1. Area <a id="prd-m2c7"></a>\nCovered in design-q9q9 \xe2\x80\x94 later.\n## Plain\n' > "$bad/docs/prd.md"
printf '# Proposal\n' > "$bad/docs/proposals/x.md"
for _ in $(seq 601); do echo; done > "$bad/docs/long.md"
expect bad "$bad" "docs/prd.md:2: em dash
warn docs/long.md: 601 lines, past 600; move what belongs elsewhere
README.md:1: broken link to missing.md
docs/README.md: doesn't link long.md
docs/README.md: doesn't link proposals/x.md
docs/prd.md:2: cites design-q9q9, which doesn't exist
docs/prd.md:3: heading has no ID; run just fmt"

# Planned sections, milestone files and qualified citations.
lifecycle="$tmp/lifecycle"
mkdir -p "$lifecycle/docs/plan" "$lifecycle/docs/user"
cat > "$lifecycle/docs/README.md" <<'MD'
[prd.md](prd.md) [ux.md](ux.md) [design.md](design.md) [plan.md](plan.md)
MD
cat > "$lifecycle/docs/prd.md" <<'MD'
## 1. Sync <a id="prd-m2c7"></a>
1. **Edits reach every device.** <a id="prd-4hz8"></a> **Planned:** M2. They do.
MD
cat > "$lifecycle/docs/ux.md" <<'MD'
## 1. Flows <a id="ux-c3pa"></a>
### 1.1 Sign in <a id="ux-k2rf"></a>
Serves [PRD: Sync](prd.md#prd-m2c7). The API is described in api:design-7kq3.
MD
cat > "$lifecycle/docs/design.md" <<'MD'
## 1. Overview <a id="design-q2m8"></a>
**Planned:** M1
Follows [UX: Sign in](ux.md#ux-k2rf).
```markdown
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
printf '**Planned:** M7
' >> "$drift/docs/design.md"
printf '**Planned:** M1
' >> "$drift/docs/user/README.md"
printf '# M3. Third
' > "$drift/docs/plan/M3.md"
expect drift "$drift" "docs/plan.md: doesn't link plan/M3.md
docs/design.md:8: planned for M7, which isn't in the plan
docs/user/README.md:2: planned marker in user docs"

# Citations in code are checked, except in files marked as examples.
code="$tmp/code"
cp -R "$lifecycle" "$code"
mkdir -p "$code/src"
printf '// Sign in, ux-k2rf. Gone, design-p2x9.\n' > "$code/src/auth.go"
printf 'design-p2x9\n' > "$code/src/fixture.txt"
printf 'src/fixture.txt devkit-examples\n' > "$code/.gitattributes"
(cd "$code" && git init -q && git add -A)
expect code "$code" "src/auth.go:1: cites design-p2x9, which doesn't exist"

expect empty "$tmp" "ok   docs (none found)"

(( failures == 0 ))
