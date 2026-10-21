#!/usr/bin/env bash
# Numbers the sections of the PRD, ux.md and design in reading order, gives
# each one an ID, and turns citations into links titled with their target
# (CONVENTIONS.md section 2). Managed by devkit: only devkit's upgrade
# replaces this file.
# Usage: fmt-docs.sh [--check | --adopt] [project-root]
#   --check  change nothing, and report what fmt would change and the
#            citations it can't fix. Needs no history, so it runs in CI.
#   --adopt  first bring v1 docs over: join docs split by chapter, keep each
#            old number as an extra anchor, turn **R1.2** items into numbered
#            requirements, and list old IDs found outside docs/.
# Paths never contain spaces (CONVENTIONS.md section 7), so lists of paths
# are split on whitespace.
# The awk programs are single-quoted, so $ there is awk's.
# shellcheck disable=SC2086,SC2016
set -euo pipefail

mode=fix
case "${1:-}" in --check | --adopt) mode=${1#--}; shift ;; esac
cd "${1:-.}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
: > "$tmp/msgs"
: > "$tmp/old"

git=0
git rev-parse --is-inside-work-tree > /dev/null 2>&1 && git=1
idpat='(prd|ux|design)-[0-9a-z]{4}'

# Replaces a file with $tmp/out if they differ. awk and sed end every line
# with a newline, so a file without a final newline keeps going without one.
put() { # file
  local s
  if [[ -s "$1" && -n $(tail -c 1 "$1") ]]; then
    s=$(cat "$tmp/out")
    printf '%s' "$s" > "$tmp/out"
  fi
  cmp -s "$tmp/out" "$1" || cat "$tmp/out" > "$1"
}

# Shared awk: ID patterns and parsing of headings, requirements and anchors.
common='
function setup() {
  ALPHA = "0123456789abcdefghjkmnpqrstvwxyz"
  C = "[" ALPHA "]"
  NEWRE = "(prd|ux|design)-" C C C C
  OLDRE = "[DRU][0-9]+([.][0-9]+)*"
  FENCE = "^[ \t]*(```|~~~)"
  LINKRE = "\\[[^]]*\\]\\([^)]*\\)"
}
# A section ID of the given doc, or of any doc when kind is empty.
function valid(id, kind,   s) {
  if (id !~ ("^" NEWRE "$")) return 0
  if (kind != "" && index(id, kind "-") != 1) return 0
  s = substr(id, index(id, "-") + 1)
  return s ~ /[0-9]/ && s ~ /[a-z]/
}
function first(list,   a) { split(list, a, " "); return a[1] }
# Splits trailing anchors off s into R_TEXT and R_ANCH.
function strip_anchors(s,   a, out) {
  out = ""
  while (match(s, /[ \t]*<a id="[^"]*"><\/a>[ \t]*$/)) {
    a = substr(s, RSTART, RLENGTH); s = substr(s, 1, RSTART - 1)
    sub(/^[ \t]*<a id="/, "", a); sub(/"><\/a>[ \t]*$/, "", a)
    out = (out == "") ? a : a " " out
  }
  R_TEXT = s; R_ANCH = out
}
# Splits leading anchors off s into R_ANCH and R_TEXT.
function lead_anchors(s,   a, out) {
  out = ""
  while (match(s, /^[ \t]*<a id="[^"]*"><\/a>/)) {
    a = substr(s, RSTART, RLENGTH); s = substr(s, RLENGTH + 1)
    sub(/^[ \t]*<a id="/, "", a); sub(/"><\/a>$/, "", a)
    out = (out == "") ? a : out " " a
  }
  sub(/^[ \t]+/, "", s)
  R_TEXT = s; R_ANCH = out
}
# Sets H_LEVEL, H_NUM, H_TITLE and H_ANCH. A number is "3." or "3.2", so a
# title such as "2025 roadmap" keeps its digits.
function parse_heading(line,   t) {
  match(line, /^#+/); H_LEVEL = RLENGTH
  t = substr(line, RLENGTH + 1); sub(/^[ \t]+/, "", t)
  strip_anchors(t); t = R_TEXT; H_ANCH = R_ANCH
  sub(/[ \t]+$/, "", t)
  H_NUM = ""
  if (match(t, /^[0-9]+\.[ \t]+/) || match(t, /^[0-9]+(\.[0-9]+)+\.?[ \t]+/)) {
    H_NUM = substr(t, 1, RLENGTH); sub(/[. \t]+$/, "", H_NUM)
    t = substr(t, RLENGTH + 1)
  }
  H_TITLE = t
}
# A requirement is a numbered item with a bold lead. Sets R_BOLD, R_TITLE,
# R_ANCH and R_REST.
function parse_req(line,   rest, end) {
  rest = line; sub(/^[0-9]+\. \*\*/, "", rest)
  end = index(rest, "**")
  if (end < 2) return 0
  R_BOLD = substr(rest, 1, end - 1)
  lead_anchors(substr(rest, end + 2)); R_REST = R_TEXT
  R_TITLE = R_BOLD; sub(/[.:]$/, "", R_TITLE)
  return 1
}
'

# Section docs are one file each (CONVENTIONS.md section 5).
kinds=""
for k in prd ux design; do [[ -f "docs/$k.md" ]] && kinds="$kinds $k"; done

if [[ $mode == adopt ]]; then
  # Join each doc split by chapter, top file first, then its chapter files
  # in contents order. Chapter headings move up a level if they start at #.
  # A chapter file is named by its number, as in 3-sync.md or 4.1-retries.md,
  # and files the contents list doesn't link follow in number order.
  for k in $kinds; do
    chapters=$( { ls docs/$k/ 2> /dev/null || true; } | grep -E '^[0-9]+(\.[0-9]+)*-.*\.md$' || true)
    [[ -n "$chapters" ]] || continue
    order=$(for c in $chapters; do
      n=$(grep -n -F "($k/$c" "docs/$k.md" | head -n 1 | cut -d: -f1)
      echo "${n:-99999} ${c%%-*} $c"
    done | sort -k1,1n -k2,2V | cut -d' ' -f3)
    for c in $order; do
      printf '\n' >> "docs/$k.md"
      awk -v dir="$k" 'BEGIN { demote = 0 }
        /^[ \t]*(```|~~~)/ { fence = !fence; print; next }
        fence { print; next }
        /^#/ && !seen { seen = 1; if ($0 ~ /^# /) demote = 1 }
        /^#/ && demote { $0 = "#" $0 }
        { line = $0; out = ""
          while (match(line, /\]\([^)#:]+[)#]/)) {
            out = out substr(line, 1, RSTART + 1)
            p = substr(line, RSTART + 2, RLENGTH - 3)
            if (p ~ /^\.\.\//) p = substr(p, 4); else p = dir "/" p
            out = out p
            line = substr(line, RSTART + RLENGTH - 1)
          }
          print out line }' "docs/$k/$c" >> "docs/$k.md"
      rm "docs/$k/$c"
      echo "joined docs/$k/$c into docs/$k.md"
    done
    rmdir "docs/$k" 2> /dev/null || true
    # Links to a chapter file now go to the doc.
    find docs -name '*.md' -type f | while read -r f; do
      sed -E "s|\]\(((\.\./)*)$k/[0-9]+(\.[0-9]+)*-[^)#]*\.md|](\1$k.md|g" "$f" > "$tmp/out"
      put "$f"
    done
  done

  # Keep each v1 number as an extra anchor, so citations of it resolve.
  for k in $kinds; do
    letter=D; [[ $k == ux ]] && letter=U
    awk -v kind="$k" -v L="$letter" '
      /^[ \t]*(```|~~~)/ { fence = !fence; print; next }
      fence || /<a id="/ { print; next }
      kind != "prd" && /^##+[ \t]+[0-9]+(\.[0-9]+)*\.?[ \t]/ {
        n = $0; sub(/^#+[ \t]+/, "", n); sub(/[ \t].*/, "", n); sub(/\.$/, "", n)
        print $0 " <a id=\"" L n "\"></a>"; next
      }
      kind == "prd" && /^##+[ \t]+R[0-9]+(\.[0-9]+)*\.?[ \t]/ {
        match($0, /^#+[ \t]+/); h = substr($0, 1, RLENGTH); t = substr($0, RLENGTH + 1)
        match(t, /^R[0-9]+(\.[0-9]+)*/); id = substr(t, 1, RLENGTH)
        t = substr(t, RLENGTH + 1); sub(/^\.?[ \t]+/, "", t)
        print h t " <a id=\"" id "\"></a>"; next
      }
      kind == "prd" && /^[-*] \*\*R[0-9]+(\.[0-9]+)*/ {
        s = $0; sub(/^[-*] \*\*/, "", s)
        match(s, /^R[0-9]+(\.[0-9]+)*/); id = substr(s, 1, RLENGTH); s = substr(s, RLENGTH + 1)
        c = index(s, "**"); bold = substr(s, 1, c - 1); rest = substr(s, c + 2)
        sub(/^\.?[ \t]*/, "", bold); sub(/^[ \t]+/, "", rest)
        planned = ""
        if (bold == "") {
          if (match(rest, /^\*\*Planned:\*\* M[0-9]+\.?[ \t]*/)) {
            planned = substr(rest, 1, RLENGTH); rest = substr(rest, RLENGTH + 1)
            sub(/[ \t]+$/, "", planned); if (planned !~ /\.$/) planned = planned "."
          }
          if (match(rest, /\. /)) { bold = substr(rest, 1, RSTART); rest = substr(rest, RSTART + 2) }
          else { bold = rest; rest = "" }
        }
        out = "1. **" bold "** <a id=\"" id "\"></a>"
        if (planned != "") out = out " " planned
        if (rest != "") out = out " " rest
        print out; next
      }
      { print }' "docs/$k.md" > "$tmp/out"
    put "docs/$k.md"
  done
fi

# Every heading and requirement, with its title and anchors.
section_files=""
for k in $kinds; do section_files="$section_files docs/$k.md"; done
: > "$tmp/rows"
if [[ -n "$section_files" ]]; then
  awk "$common"'
    BEGIN { setup(); OFS = "\t" }
    FNR == 1 { fence = 0; kind = FILENAME; sub(/^docs\//, "", kind); sub(/\.md$/, "", kind) }
    $0 ~ FENCE { fence = !fence; next }
    fence { next }
    /^##+[ \t]/ { parse_heading($0); print kind, FILENAME, FNR, "h", H_LEVEL, H_TITLE, H_ANCH; next }
    kind == "prd" && /^[0-9]+\. \*\*/ && parse_req($0) { print kind, FILENAME, FNR, "r", 0, R_TITLE, R_ANCH }
  ' $section_files > "$tmp/rows"
fi

# IDs already taken, in the tree and its history, and those defined at HEAD.
# New IDs avoid all of them, and a hand-written ID found only in history is
# replaced, so an old commit never points at the wrong section.
: > "$tmp/used"; : > "$tmp/hist"; : > "$tmp/head"
shallow=0
if [[ $mode != check ]]; then
  if (( git )); then
    [[ $(git rev-parse --is-shallow-repository 2> /dev/null) == true ]] && shallow=1
    { git grep --untracked -ohIE "$idpat" 2> /dev/null || true; } > "$tmp/used"
    if git rev-parse --verify --quiet HEAD > /dev/null; then
      { git log --all --format=%B; git log --all -p --format= -- docs; } 2> /dev/null \
        | { grep -oE "$idpat" || true; } | sort -u > "$tmp/hist"
      for k in $kinds; do
        { git show "HEAD:docs/$k.md" 2> /dev/null || true; } \
          | { grep -oE 'id="[^"]+"' || true; } | sed 's/^id="//; s/"$//'
      done > "$tmp/head"
    fi
  else
    { grep -rhoE "$idpat" . 2> /dev/null || true; } > "$tmp/used"
  fi
  cat "$tmp/hist" >> "$tmp/used"
fi

# Gives every section a main ID of its own doc, minting where needed, and
# writes the table of sections and the map from each anchor to its section.
seed=$(od -An -N4 -tu4 /dev/urandom | tr -d ' \n')
status=0
awk -v mode="$mode" -v shallow="$shallow" -v seed="$seed" -v msgf="$tmp/msgs" -v idsf="$tmp/ids" \
  -v tablef="$tmp/table" -v usedf="$tmp/used" -v histf="$tmp/hist" -v headf="$tmp/head" "$common"'
  BEGIN {
    setup(); FS = OFS = "\t"; srand(seed)
    while ((getline x < usedf) > 0) used[x] = 1
    while ((getline x < histf) > 0) hist[x] = 1
    while ((getline x < headf) > 0) head[x] = 1
  }
  function msg(s) { print s >> msgf }
  function mint(kind,   s, i) {
    if (shallow) {
      print "fmt-docs.sh: new sections need IDs, which must be checked against the whole history. This is a shallow clone, so fetch it with git fetch --unshallow." > "/dev/stderr"
      exit 3
    }
    do {
      s = ""
      for (i = 0; i < 4; i++) s = s substr(ALPHA, int(rand() * 32) + 1, 1)
    } while (s !~ /[0-9]/ || s !~ /[a-z]/ || ((kind "-" s) in used))
    used[kind "-" s] = 1
    return kind "-" s
  }
  {
    kind = $1; file = $2; line = $3; level = $5; title = $6
    n = split($7, a, " ")
    where = file ":" line ": "
    what = ($4 == "h") ? "heading" : "requirement"
    if (n > 0 && valid(a[1], kind)) {
      if (mode != "check" && !(a[1] in head) && (a[1] in hist)) {
        new = mint(kind)
        print where a[1] " is in the history, so the section is now " new > "/dev/stderr"
        print a[1], new, file, title > idsf
        a[1] = new
      }
    } else if (mode == "check") {
      if (n > 0 && valid(a[1], "")) msg(where "section\047s main ID " a[1] " names another doc; give it a " kind " ID with just fmt")
      else msg(where what " has no ID; run just fmt")
    } else {
      for (i = n; i >= 1; i--) a[i + 1] = a[i]
      a[1] = mint(kind); n++
    }
    anch = ""
    for (i = 1; i <= n; i++) {
      if (a[i] in seen) msg(where "defines " a[i] ", which is already defined")
      else { seen[a[i]] = 1; print a[i], a[1], file, title > idsf }
      anch = anch (i > 1 ? " " : "") a[i]
    }
    print file, line, level, title, anch > tablef
  }
' "$tmp/rows" || status=$?
(( status == 3 )) && exit 1
(( status == 0 )) || exit "$status"
touch "$tmp/ids" "$tmp/table"

# Rewrites one file: headings, requirements and contents in a section doc,
# links and bare IDs in any doc, and IDs that name an extra anchor in code.
rewrite='
BEGIN {
  setup()
  while ((getline x < idsf) > 0) {
    split(x, f, "\t"); mainof[f[1]] = f[2]; fileof[f[2]] = f[3]; titleof[f[2]] = f[4]
  }
  nch = 0
  while (section && (getline x < tablef) > 0) {
    split(x, f, "\t")
    if (f[1] != FILE) continue
    tline[f[2]] = f[5]
    if (f[3] == 2) { chap[++nch] = f[4]; chapid[nch] = first(f[5]) }
  }
  name["docs/prd.md"] = "PRD"; name["docs/ux.md"] = "UX"; name["docs/design.md"] = "Design"
  md = FILE ~ /\.(md|markdown)$/
  if (section) find_contents()
}
# The contents list is the first run of list items before the first heading
# in which each item is a link or plain text, nested or not, and at least one
# is a link. Sets its first and last lines in cs and ce.
function find_contents(   x, n, f, start, last, links, ok) {
  cs = ce = 0; n = 0; f = 0; start = 0
  while ((getline x < FILE) > 0) {
    n++
    if (x ~ FENCE) f = !f
    if (!f && x ~ /^##+[ \t]/) break
    if (!f && x ~ /^[ \t]*([0-9]+\.|[-*+])[ \t]/) {
      if (!start) { start = n; links = 0; ok = 1 }
      last = n
      if (x ~ /^[ \t]*([0-9]+\.|[-*+]) \[[^]]*\]\([^)]*\)[ \t]*$/) links++
      else if (x ~ LINKRE) ok = 0
      continue
    }
    if (start && links && ok) break
    start = 0
  }
  close(FILE)
  if (start && links && ok) { cs = start; ce = last }
}
function change(s) { if (mode == "check") print FILE ":" FNR ": " s "; run just fmt" >> msgf }
function err(s) { print FILE ":" FNR ": " s >> msgf }
function label(m) { return fileof[m] == FILE ? titleof[m] : name[fileof[m]] ": " titleof[m] }
function rel(f,   n, p, t) {
  if (f == FILE) return ""
  t = FILE; n = gsub("/", "/", t); p = ""
  while (n-- > 1) p = p "../"
  return p substr(f, 6)
}
function tags(list,   a, n, i, s) {
  n = split(list, a, " "); s = ""
  for (i = 1; i <= n; i++) s = s (i == 1 ? " " : "") "<a id=\"" a[i] "\"></a>"
  return s
}
function link(tok,   h, text, target, hp, path, frag, m, lbl, want, new) {
  h = index(tok, "](")
  text = substr(tok, 2, h - 2); target = substr(tok, h + 2, length(tok) - h - 2)
  hp = index(target, "#")
  if (hp == 0) return tok
  path = substr(target, 1, hp - 1); frag = substr(target, hp + 1)
  if (frag in mainof) {
    m = mainof[frag]; lbl = label(m); want = rel(fileof[m])
    new = "[" lbl "](" want "#" m ")"
    if (new != tok) {
      if (frag != m) change("links " frag ", which is now " m)
      else if (text != lbl) change("link says " text " but should say " lbl)
      else change("link to " m " should point at " (want == "" ? "this doc" : want))
    }
    return new
  }
  if ((frag ~ ("^" NEWRE "$") || frag ~ ("^" OLDRE "$")) && (path == "" || path ~ /(prd|ux|design)\.md$/))
    err("links " frag ", which doesn\047t exist")
  return tok
}
# Bare IDs in text. A doc links each one, code names the main ID of its section,
# and --adopt lists old IDs in code for a person to judge.
function bare(t,   out, pn, ln, po, lo, p, len, old, id, b, a, ok, m) {
  out = ""
  while (t != "") {
    pn = match(t, NEWRE) ? RSTART : 0; ln = RLENGTH
    po = 0
    if (ctx == "doc" || adopt) { po = match(t, OLDRE) ? RSTART : 0; lo = RLENGTH }
    if (pn == 0 && po == 0) break
    if (pn > 0 && (po == 0 || pn <= po)) { p = pn; len = ln; old = 0 } else { p = po; len = lo; old = 1 }
    id = substr(t, p, len)
    b = p > 1 ? substr(t, p - 1, 1) : ""
    a = substr(t, p + len, 1)
    if (old) ok = b !~ /[A-Za-z0-9_:#\/.-]/ && a !~ /[A-Za-z0-9_]/
    else ok = b !~ /[A-Za-z0-9_:#\/"-]/ && b != "\047" && a !~ /[A-Za-z0-9_-]/ && valid(id, "")
    if (!ok) { out = out substr(t, 1, p); t = substr(t, p + 1); continue }
    out = out substr(t, 1, p - 1); t = substr(t, p + len)
    if (!(id in mainof)) {
      if (!old || ctx == "doc") err("cites " id ", which doesn\047t exist")
      out = out id; continue
    }
    m = mainof[id]
    if (ctx == "doc") {
      if (id != m) change("cites " id ", which is now " m)
      else change("cites " id " without a link")
      out = out "[" label(m) "](" rel(fileof[m]) "#" m ")"
    } else if (old) {
      print FILE ":" FNR ": " id " is now " m >> oldf
      out = out id
    } else {
      if (id != m) change("cites " id ", which is now " m)
      out = out m
    }
  }
  return out t
}
# Text outside code spans, links and anchors. In code, only Markdown has
# code spans, and links are left as they are.
function inline(s,   out, best, len, tk, tok) {
  out = ""
  if (ctx == "code" && !md) return bare(s)
  while (s != "") {
    best = 0
    if (match(s, /`[^`]*`/)) { best = RSTART; len = RLENGTH; tk = "code" }
    if (ctx == "doc" && match(s, LINKRE) && (best == 0 || RSTART < best)) { best = RSTART; len = RLENGTH; tk = "link" }
    if (match(s, /<a [^>]*><\/a>/) && (best == 0 || RSTART < best)) { best = RSTART; len = RLENGTH; tk = "html" }
    if (best == 0) return out bare(s)
    out = out bare(substr(s, 1, best - 1))
    tok = substr(s, best, len)
    out = out (tk == "link" ? link(tok) : tok)
    s = substr(s, best + len)
  }
  return out
}
function contents(   i, s) {
  s = ""
  for (i = 1; i <= nch; i++) s = s (i > 1 ? "\n" : "") i ". [" chap[i] "](#" chapid[i] ")"
  return s
}
function flush() {
  if (!incont) return
  incont = 0
  if (oldc != contents()) { if (mode == "check") print FILE ":" cstart ": contents list is out of date; run just fmt" >> msgf }
  print contents()
}
md && $0 ~ FENCE { flush(); fence = !fence; print; next }
fence { print; next }
section && /^##+[ \t]/ {
  flush(); seenh = 1
  parse_heading($0); lvl = H_LEVEL
  cnt[lvl]++; for (k = lvl + 1; k <= 9; k++) cnt[k] = 0
  num = cnt[2]; for (k = 3; k <= lvl; k++) num = num "." cnt[k]
  reqn = 0
  anch = (FNR in tline) ? tline[FNR] : H_ANCH
  new = substr("#########", 1, lvl) " " num (lvl == 2 ? "." : "") " " H_TITLE tags(anch)
  if (new != $0 && anch == H_ANCH && valid(first(anch), kind)) {
    if (H_NUM == "") change("heading has no number")
    else if (H_NUM != num) change("heading " H_NUM " is out of sequence")
    else change("heading needs formatting")
  }
  print new; next
}
section && FNR == cs { incont = 1; cstart = FNR; oldc = $0; if (FNR == ce) flush(); next }
section && incont { oldc = oldc "\n" $0; if (FNR == ce) flush(); next }
{ flush() }
section && kind == "prd" && /^[0-9]+\. \*\*/ && parse_req($0) {
  reqn++
  anch = (FNR in tline) ? tline[FNR] : R_ANCH
  head = reqn ". **" R_BOLD "**" tags(anch)
  if (head " " R_REST != $0 && head != $0 && anch == R_ANCH && valid(first(anch), kind)) {
    if ($0 !~ ("^" reqn "\\. ")) change("requirement " substr($0, 1, index($0, ".") - 1) " is out of sequence")
    else change("requirement needs formatting")
  }
  rest = inline(R_REST)
  print head (rest != "" ? " " rest : ""); next
}
{ print inline($0) }
END { flush() }
'

# The docs fmt rewrites. Analyses are evidence, so they are never rewritten.
docs=$( { find docs -name '*.md' -type f ! -path 'docs/analyses/*' 2> /dev/null || true; } | sort)
for f in $docs; do
  section=0; kind=""
  case "$f" in docs/prd.md | docs/ux.md | docs/design.md) section=1; kind=$(basename "$f" .md) ;; esac
  awk -v ctx=doc -v FILE="$f" -v section="$section" -v kind="$kind" -v mode="$mode" -v adopt=0 \
    -v idsf="$tmp/ids" -v tablef="$tmp/table" -v msgf="$tmp/msgs" -v oldf="$tmp/old" "$common$rewrite" "$f" > "$tmp/out"
  [[ $mode == check ]] || put "$f"
done

# Code is every text file outside docs/ that git tracks or would track,
# except those given the devkit-examples attribute and devkit's own scripts.
if (( git )); then
  pat=$idpat
  [[ $mode == adopt ]] && pat="$idpat|[DRU][0-9]"
  code=$( { git grep --untracked -lIE "$pat" -- . ':(exclude)docs' ':(exclude).devkit' 2> /dev/null || true; } \
    | { git check-attr --stdin devkit-examples || true; } \
    | awk -F': ' '$3 == "unspecified" || $3 == "unset" { print $1 }')
  adopt=0; [[ $mode == adopt ]] && adopt=1
  for f in $code; do
    awk -v ctx=code -v FILE="$f" -v section=0 -v kind="" -v mode="$mode" -v adopt="$adopt" \
      -v idsf="$tmp/ids" -v tablef="$tmp/table" -v msgf="$tmp/msgs" -v oldf="$tmp/old" "$common$rewrite" "$f" > "$tmp/out"
    [[ $mode == check ]] || put "$f"
  done
fi

if [[ -s "$tmp/old" ]]; then
  echo "These lines outside docs/ name old IDs. Rewrite each one that cites a section to the new ID:"
  cat "$tmp/old"
fi
sort -s -t: -k1,1 -k2,2n "$tmp/msgs"
[[ ! -s "$tmp/msgs" ]]
