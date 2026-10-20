# Proposal: Section IDs that don't depend on position

- **Status:** draft

Give each section of the PRD, UX doc and design a short ID that names its doc and never changes, such as `design-7kq3`, and generate the section numbers readers see. Docs and code refer to sections with links to the ID, and in docs the link text is the current number, so references read naturally and stay correct after any restructure. Commits cite the bare ID, which keeps working however the docs are reorganized.

1. [Problem](#1-problem)
2. [Goals and non-goals](#2-goals-and-non-goals)
3. [Dependencies](#3-dependencies)
4. [Proposal](#4-proposal)
5. [Work](#5-work)
6. [Alternatives considered](#6-alternatives-considered)
7. [Open questions](#7-open-questions)

## 1. Problem

A section's ID is its heading number. `D4.2` means the second section of chapter 4 of the design, and the linter reads IDs straight from numbered headings (D13). The ID does two jobs at once: it shows where the section sits, and it is what code and commits cite.

Those jobs conflict as a doc grows. Chapters need merging, splitting, reordering and adding, but changing a number would change what every citation means. Commit messages can't be rewritten, so `git log --grep` would find the wrong history, and qualified citations in other repos would point at the wrong section (R17).

The v2 conventions committed locally as D20 handle this by keeping numbers fixed and letting them run out of order. A design restructured that way reads:

```markdown
## 4. Document lifecycles
## 15. The product lifecycle
## 16. Roles and team size
## 5. Plugin structure
...
## 10. Alternatives considered
```

The numbers no longer help a reader find their way, and a new reader would assume a mistake. devkit's own design already shows the pressure: Alternatives considered and Open questions are chapters 10 and 11, with nine chapters after them, because new chapters could only go at the end.

Numbered IDs also race. Two branches adding a design section both take the next free number, and one renumbers on rebase (D10.18).

## 2. Goals and non-goals

### 2.1 Goals

- Section numbers on the page are always in reading order.
- References between docs read as plain section numbers and can be clicked.
- Reordering, merging, splitting, promoting or removing sections keeps every reference and citation working.
- An ID says which doc it belongs to, so a reader of code knows what it is and where to look.
- IDs stay short enough to cite in a code comment or commit subject, and imply no order.
- Two branches can add sections without colliding.
- Adding a section stays as easy as writing a heading.

### 2.2 Non-goals

- GitHub's own heading anchors, which come from heading text and change when numbers do. Links use the ID anchors instead.
- Plan IDs. Milestones and tasks keep `M3` and `M3.2`, as section 7 discusses.
- Rewriting history. Old commits keep citing old IDs, which still resolve.

## 3. Dependencies

- **The unpushed v2 commits.** Local main holds `0787b4a`, which adds conventions v2 with fixed numbers and aliases (D20), and `a6ac5b2`, which upgrades devkit to it. Neither has been pushed, so no project has v2. If this proposal is accepted, v2 is rewritten to this design instead of adding v3. Not met: the commits should stay unpushed until this is decided.

## 4. Proposal

### 4.1 What a reader sees

A design doc renders as numbered sections with references written as section numbers:

> **3.2 Retries**
>
> **Planned:** M4
>
> A failed sync retries with backoff, up to five attempts (PRD §1.2). Edits wait in the queue until the server confirms them (§3.1).

Each § reference is a link. Clicking it goes to that section, in this doc or another. Nothing on the page is an ID.

### 4.2 What the source looks like

The same section in markdown:

```markdown
### 3.2 Retries <a id="design-7kq3"></a>

**Planned:** M4

A failed sync retries with backoff, up to five attempts ([PRD §1.2](prd.md#prd-4hz8)).
Edits wait in the queue until the server confirms them ([§3.1](#design-b6tn)).
```

- **The heading** ends with an anchor holding the section's ID. Renderers such as GitHub and VS Code don't show it, and it doesn't depend on the heading text.
- **A reference** is a link to the ID. Its text is the target's current number, with the doc's name when it is in another doc: "§3.1", "PRD §1.2", "UX §2.1", "design §3.2".
- **The § sign** keeps a reference from looking like an ID. `R1.2` would read like the old IDs, and someone would copy it into a code comment that breaks at the next renumber.

A whole design doc:

```markdown
# Notes: Design

1. [Overview](#design-q2m8)
2. [Storage](#design-k9vd)
3. [Sync](#design-r3wq)
4. [Alternatives considered](#design-w5jh)

## 1. Overview <a id="design-q2m8"></a>

Notes keeps every edit on the device first and syncs in the background
([PRD §1.1](prd.md#prd-m2c7)).

## 2. Storage <a id="design-k9vd"></a>

## 3. Sync <a id="design-r3wq"></a>

### 3.1 Queue <a id="design-b6tn"></a>

### 3.2 Retries <a id="design-7kq3"></a>

## 4. Alternatives considered <a id="design-w5jh"></a>
```

The PRD works the same way, with an anchor after each requirement's title:

```markdown
### 1. Sync <a id="prd-m2c7"></a>

1. **Edits reach every device.** <a id="prd-4hz8"></a> An edit made offline
   appears on the user's other devices within a minute of reconnecting.
2. **Conflicts never lose text.** <a id="prd-9tqe"></a> When two devices edit
   the same note, both versions are kept.
```

Plan tasks and proposals refer to sections with the same links, such as `[design §3.2](../design.md#design-7kq3)`.

### 4.3 Code and commits

Code links to the section by its repo path and ID:

```go
// Give up after five attempts so a dead server can't drain the battery.
// See docs/design.md#design-7kq3.
const maxAttempts = 5
```

The path tells a reader which file to open, and editors that follow file paths open it at the section. It works the same in any language's comments, since it is plain text. `just fmt` keeps the path current when a section moves to another chapter file, as in `docs/design/sync.md#design-7kq3`. Where a path doesn't fit, such as a short inline comment, the bare ID is enough: `// design-7kq3`.

Commit messages cite the bare ID, since subjects are short:

```text
Retry failed syncs with backoff so edits survive a dropped link, design-7kq3

Change: fixed
Changelog: Edits made offline are no longer lost if the connection drops.
```

Every form contains the same ID, so `git grep design-7kq3` finds the code and docs about a section, and `git log --grep design-7kq3` finds its commits, wherever it has moved. To find a section's ID, read its heading in the source, or copy it from any link that points there. Agents read the source, so they see IDs directly.

### 4.4 The ID

An ID is the doc's name, a hyphen, and four characters: `prd-4hz8` for a requirement, `ux-c3pa` for a UX section, `design-7kq3` for a design section.

- **The doc name** replaces the R, U and D letters. Out of context, `design-7kq3` says what it points at, where `D-7kq3` means nothing to someone who doesn't know devkit. Other repos' IDs are qualified the same way, as in `api:design-7kq3`.
- **The same string** is the anchor, the link fragment, the code citation and the commit citation. It uses only letters, digits and a hyphen, so no comment syntax, shell, URL, YAML or chat tool treats it specially.
- **Characters** are lowercase Crockford base32, which leaves out `i`, `l`, `o` and `u` so no two look alike. Each ID has at least one digit, so none reads as a word.
- **There are about a million** per kind. New IDs are checked against the ones in the repo, so a clash can only happen between two branches adding sections at once, and the linter catches it on merge.
- **An ID is never reused**, even after its section is gone.

Four characters is the shortest that keeps cross-branch clashes rare in a doc with hundreds of sections, while staying easy to type and read aloud. The pattern `(prd|ux|design)-[0-9a-z]{4}` with a required digit matches no ordinary words, such as `design-time`, so grep and the linter find citations in code without false hits.

### 4.5 `just fmt` does the bookkeeping

Nobody writes a number, an ID or a link's text by hand. A new script, `.devkit/fmt-docs.sh`, run by `just fmt`:

1. Numbers every heading in the PRD, UX doc and design in reading order.
2. Gives a fresh ID to any heading or requirement that lacks one.
3. Turns each bare ID in a doc into a link, and rewrites every link's text and path to match its target.
4. Rewrites the contents list.

Adding a section is writing a plain heading:

```markdown
### Conflict resolution

Two edits to the same note are both kept (design-7kq3).
```

After `just fmt`:

```markdown
### 3.3 Conflict resolution <a id="design-h8fm"></a>

Two edits to the same note are both kept ([§3.2](#design-7kq3)).
```

So an agent or person can write a bare ID anywhere in a doc, and `fmt` makes it a readable link.

Analyses are never rewritten, so `fmt` leaves them alone. Their links keep working through the anchors, though the number in the text may be out of date.

A split doc names its chapter files by slug, as in `docs/design/sync.md`, so renumbering never renames a file. If a section moves to another chapter file, `fmt` rewrites the paths of links to it.

### 4.6 Restructuring

Each move is an edit to the text followed by `just fmt`. Starting from the design in section 4.2:

**Reorder.** Move Sync above Storage. Headings and every link to them now say §2 and §2.1, and the IDs don't change.

```markdown
## 2. Sync <a id="design-r3wq"></a>
### 2.1 Queue <a id="design-b6tn"></a>
### 2.2 Retries <a id="design-7kq3"></a>
## 3. Storage <a id="design-k9vd"></a>
```

**Merge.** Fold Queue into Retries. The surviving heading keeps the absorbed ID as a second anchor, so old links and citations still land there:

```markdown
### 2.1 Retries <a id="design-7kq3"></a><a id="design-b6tn"></a>

Edits wait in a local queue until the server confirms them. A failed sync
retries with backoff.
```

`fmt` points links to `design-b6tn` at `design-7kq3`. A code comment that cites `design-b6tn` is found by grep at the merged section.

**Split.** The original ID stays with the part that keeps the main meaning. The new part gets a new ID from `fmt`. Links and citations whose meaning moved to the new part are updated in the same commit.

**Promote or demote.** Turn Retries into its own chapter. Its ID moves with it, so only numbers change.

**Remove.** Built text that is gone leaves its ID as an extra anchor on the section closest in meaning. Dropped planned work moves to Alternatives considered, which keeps its anchor.

The commit says what moved, so history is easy to follow:

```text
Fold the sync queue into retries, since one can't change without the other

Restructure only. design-b6tn merged into design-7kq3. design-r3wq moved before design-k9vd.

Change: docs
```

### 4.7 What the linter checks

`lint-docs.sh` fails when `fmt` would change something, and on mistakes `fmt` can't fix:

```text
docs/design.md:14: heading 3.4 is out of sequence; run just fmt
docs/design.md:22: heading has no ID; run just fmt
docs/plan/M4.md:8: link says §3.1 but design-7kq3 is §3.2; run just fmt
docs/ux.md:31: links design-b6tn, which is now design-7kq3; run just fmt
docs/prd.md:18: links prd-zz99, which doesn't exist
docs/design.md:40: defines design-7kq3, which is already defined
docs/design.md: design-p2x9 is gone; keep it as an anchor where its text went
src/sync/retry.go:12: links docs/design.md#design-7kq3, which is in docs/design/sync.md; run just fmt
src/sync/queue.go:4: cites design-zz99, which doesn't exist
```

The "is gone" check compares with the base commit, the upstream branch by default, so a section can't disappear without its ID going somewhere.

Today the linter leaves code to `audit`, since identifiers such as `R2` mean other things in code (D13). The new IDs can't be mistaken for anything else, so the linter checks citations in code too.

### 4.8 Moving existing projects

The v1 to v2 migration runs `fmt-docs.sh --adopt`. It gives each section a new ID, keeps the old number as a second anchor, and turns references in docs into links:

Before:

```markdown
### 4.2 Retries

Up to five attempts, R1.2.
```

After:

```markdown
### 4.2 Retries <a id="design-7kq3"></a><a id="D4.2"></a>

Up to five attempts, [PRD §1.2](prd.md#prd-4hz8).
```

Old citations in code and history keep resolving, since grep finds `D4.2` at the section. The migration offers to rewrite code comments to links with the new IDs, and leaves the choice to the user. After that, the project can reorder freely, and the numbers stay right.

### 4.9 Docs this changes

- **CONVENTIONS.md:** section 2 describes IDs, anchors, links and generated numbers. Section 5 names chapter files by slug. Section 7 adds `fmt-docs.sh` to the managed files and `just fmt`. Section 18, from v2, becomes the restructure rules above.
- **Templates:** the PRD, UX and design templates use anchored headings and linked references. The justfile template runs `fmt-docs.sh` from `fmt`.
- **Agents block:** link sections from code as `docs/design.md#design-7kq3`, cite the bare ID in commits, write references in docs as bare IDs or links, run `just fmt` after editing docs or moving sections, and grep a section's ID and its extra anchors for history.
- **Skills:** `restructure` reduces to moving text, keeping anchors and running `just fmt`. The doc skills and `design-review` stop choosing numbers. `audit` and `upgrade` learn the new form.
- **devkit's design:** D3's paragraph on stable IDs, D13 and D20 describe this. D13 gains the check of citations in code. D10.18, "IDs that can't collide", is reversed: random IDs are now the choice, and numbered IDs move to Alternatives considered. A new alternative records v2's fixed numbers.
- **devkit's PRD:** R17 adds that reorganizing a doc never breaks a citation, as v2 already does.
- **devkit's own docs** migrate as any project would, which shows the result on a real 600-line design.

## 5. Work

One milestone, done when devkit's own docs are on the new form and `just check` passes.

1. Rework `lint-docs.sh` and its tests for anchors, links, numbering order, citations in code and the base check.
2. Write `fmt-docs.sh` with `--adopt`, with tests for numbering, new IDs, links, contents, chapter paths in docs and code, and adoption.
3. Check on a scratch repo that GitHub and VS Code render the anchors and follow the links in docs, and which editors open the paths in code comments.
4. Rewrite v2's conventions, changelog, templates, agents block and skills.
5. Migrate devkit's PRD and design, and restructure its design into reading order.

## 6. Alternatives considered

### 6.1 Fixed numbers that run out of order

v2 as committed. It needs no new script, but the page shows numbers like 4, 15, 16, 5, which help nobody find their way and look like mistakes.

### 6.2 Renumbering and rewriting citations

A restructure could renumber and rewrite every citation. Code and docs can be rewritten, but commit messages and other repos can't, so history and cross-repo citations would point at the wrong sections.

### 6.3 Visible IDs in headings

Headings could show the ID, as in `### 3.2 Retries [design-7kq3]`, and docs could cite bare IDs. Anyone could see what to cite, but every heading and reference shows a code that means nothing to a reader, and references can't be clicked.

### 6.4 A kind letter: `D-7kq3`

Short, and close to today's `D4.2`. But in code it means nothing to someone who doesn't know devkit, and a single letter matches too much to check code reliably.

### 6.5 Link style: `design#7kq3`

Reads as "this section of the design", like the links in docs. But `#` means something to chat tools, issue trackers and markdown at the start of a line, and a split doc breaks the literal mapping to a file.

### 6.6 A tool prefix: `devkit:D-7kq3`

Says which system the ID belongs to, but not which doc. It is long, and it clashes with the `api:` qualifier for other repos.

### 6.7 Names instead of random IDs

Stable names, as the C++ standard uses, such as `design-retry-backoff`, read well. But a name invites renaming when the section's scope drifts, names get long in code comments, and two sections can want the same name. A random ID has no meaning to drift from.

### 6.8 Sequential IDs

A counter per kind, as IBM DOORS uses, gives short IDs like `design-47`. But they still look ordered, and two branches still race for the next one.

### 6.9 No section numbers

Drop numbers and link with section titles instead. It is equally readable, but titles get long in running text, and "see 3.2" is how people talk about a long doc.

## 7. Open questions

- **Opening links from code.** A path with a fragment is plain text in a comment. Some editors open it at the file, fewer at the section. Is the path worth its length where no editor follows it, or should short comments default to the bare ID? Task 3 shows what works.
- **Link text.** Should a reference show only the number, "§3.2", or the number and title, "§3.2 Retries"? Titles help a reader decide whether to click, but make sentences longer.
- **Plan IDs.** Milestones are reordered sometimes, and tasks are cited in commits. They could use IDs and links too. They are left alone here because the plan is ordered work that gets deleted when done, and "M3" is easy to say. Is that the right line?
