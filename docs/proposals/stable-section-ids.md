# Proposal: Section IDs that don't depend on position

- **Status:** draft

Give each section of the PRD, UX doc and design a short random ID, such as `D-7kq3`, that never changes, and let the section numbers readers see be regenerated whenever the doc is reorganized. Docs can then be restructured freely while every citation in code, commits and other repos keeps working, and the numbers on the page are always in order.

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
- Reordering, merging, splitting, promoting or removing sections keeps every citation working.
- IDs stay short enough to cite in a code comment or commit subject.
- IDs imply no order, so nobody expects them to match the page.
- Two branches can add sections without colliding.
- Adding a section stays as easy as writing a heading.

### 2.2 Non-goals

- Links from outside the repo to a heading anchor. GitHub builds anchors from heading text, which changes when numbers do. Citations use IDs, not links.
- Plan IDs. Milestones and tasks keep `M3` and `M3.2`, as section 7 discusses.
- Rewriting history. Old commits keep citing old IDs, which still resolve through aliases.

## 3. Dependencies

- **The unpushed v2 commits.** Local main holds `0787b4a`, which adds conventions v2 with fixed numbers and aliases (D20), and `a6ac5b2`, which upgrades devkit to it. Neither has been pushed, so no project has v2. If this proposal is accepted, v2 is rewritten to this design instead of adding v3. Not met: the commits should stay unpushed until this is decided.

## 4. Proposal

### 4.1 What it looks like

A design doc keeps its numbered headings. Each heading ends with the section's ID in brackets:

```markdown
# Notes: Design

1. [Overview](#1-overview-d-q2m8)
2. [Storage](#2-storage-d-k9vd)
3. [Sync](#3-sync-d-r3wq)
4. [Alternatives considered](#4-alternatives-considered-d-w5jh)

## 1. Overview [D-q2m8]

Notes keeps every edit on the device first and syncs in the background.

## 2. Storage [D-k9vd]

## 3. Sync [D-r3wq]

### 3.1 Queue [D-b6tn]

Edits wait in a local queue until the server confirms them.

### 3.2 Retries [D-7kq3]

**Planned:** M4

A failed sync retries with backoff, up to five attempts (R-4hz8).

## 4. Alternatives considered [D-w5jh]
```

Rendered, a reader sees "3.2 Retries [D-7kq3]". The number says where they are. The ID is what they cite.

Code and commits cite the ID, as they cite numbers today:

```go
// Give up after five attempts so a dead server can't drain the battery, D-7kq3.
const maxAttempts = 5
```

```text
Retry failed syncs with backoff so edits survive a dropped link, D-7kq3

Change: fixed
Changelog: Edits made offline are no longer lost if the connection drops.
```

`git log --grep D-7kq3` finds every commit about that section, wherever it has moved.

The PRD works the same way. A requirement's ID follows its title:

```markdown
## Requirements

### 1. Sync [R-m2c7]

1. **Edits reach every device.** [R-4hz8] An edit made offline appears on the user's other devices within a minute of reconnecting.
2. **Conflicts never lose text.** [R-9tqe] When two devices edit the same note, both versions are kept.
```

The UX doc uses `U-` IDs on its headings, exactly like the design.

### 4.2 The ID

An ID is the kind letter, a hyphen, and four characters: `D-7kq3`, `R-4hz8`, `U-c3pa`.

- **Kinds** stay as they are: R for requirements, U for UX sections, D for design sections. Other repos' IDs are qualified the same way, as in `api:D-7kq3`.
- **Characters** are lowercase Crockford base32, which leaves out `i`, `l`, `o` and `u` so no two look alike. Each ID has at least one digit, so none reads as a word.
- **There are about a million** per kind. New IDs are checked against the ones in the repo, so a clash can only happen between two branches adding sections at once, and the linter catches it on merge.
- **An ID is never reused**, even after its section is gone.

Four characters is the shortest that keeps cross-branch clashes rare in a doc with hundreds of sections, while staying easy to type and read aloud.

### 4.3 Numbers are generated

Nobody writes or edits a number or an ID by hand. A new script, `.devkit/fmt-docs.sh`, run by `just fmt`:

1. Numbers every heading in the PRD, UX doc and design in reading order.
2. Gives a fresh ID to any heading that lacks one.
3. Rewrites the contents list to match.

Adding a section is writing a plain heading:

```markdown
### Conflict resolution
```

After `just fmt`:

```markdown
### 3.3 Conflict resolution [D-h8fm]
```

The linter fails if numbers are out of sequence or a heading has no ID, with a message to run `just fmt`. So the numbers on main are always right.

A split doc names its chapter files by slug, as in `docs/design/sync.md`, so renumbering never renames a file. The contents in `docs/design.md` gives the order.

### 4.4 Restructuring

Each move is an edit to the text followed by `just fmt`. Starting from the design in section 4.1:

**Reorder.** Move Sync above Storage. The numbers follow, and the IDs don't change.

```markdown
## 2. Sync [D-r3wq]
### 2.1 Queue [D-b6tn]
### 2.2 Retries [D-7kq3]
## 3. Storage [D-k9vd]
```

**Merge.** Fold Queue into Retries. The surviving section lists the absorbed ID on an `**Also:**` line, after any planned marker:

```markdown
### 2.1 Retries [D-7kq3]

**Also:** D-b6tn

Edits wait in a local queue until the server confirms them. A failed sync retries with backoff.
```

A comment that cites `D-b6tn` still resolves, to Retries.

**Split.** The original ID stays with the part that keeps the main meaning. The new part gets a new ID from `just fmt`. Citations whose meaning moved to the new part are updated in the same commit.

**Promote or demote.** Turn Retries into its own chapter. Its ID moves with it, so nothing else changes:

```markdown
## 3. Retries [D-7kq3]
```

**Remove.** Built text that is gone leaves its ID as an alias of the section closest in meaning. Dropped planned work moves to Alternatives considered, which lists its ID.

The commit says what moved, so history is easy to follow:

```text
Fold the sync queue into retries, since one can't change without the other

Restructure only. D-b6tn merged into D-7kq3. D-r3wq moved before D-k9vd.

Change: docs
```

### 4.5 What the linter checks

`lint-docs.sh` keeps v2's checks, with simpler rules since IDs no longer nest:

```text
docs/design.md:14: heading 3.4 is out of sequence; run just fmt
docs/design.md:22: heading has no ID; run just fmt
docs/design.md:40: defines D-7kq3, which is already defined
docs/ux.md:31: cites D-b6tn, which is now D-7kq3
docs/prd.md:18: cites R-zz99, which doesn't exist
docs/design.md: D-p2x9 is gone; list it under **Also:** where its text went
```

The last check compares with the base commit, the upstream branch by default, so a section can't disappear without its ID going somewhere. Docs cite current IDs. Code and commits may keep citing aliases.

### 4.6 Moving existing projects

The v1 to v2 migration runs `fmt-docs.sh --adopt`, which gives each section a new ID and keeps its old number as an alias:

```markdown
### 3.2 Retries [D-7kq3]

**Also:** D4.2
```

Before:

```markdown
### 4.2 Retries
```

Old citations keep resolving, so nothing in code or history breaks. The migration then offers to rewrite citations in docs and code comments to the new IDs. Docs must be rewritten, since they cite only current IDs. Code is the user's choice. After that, the project can reorder freely.

The old positional form, such as `D4.2`, is accepted only in `**Also:**` lines and in code, so it can't come back into use.

### 4.7 Docs this changes

- **CONVENTIONS.md:** section 2 describes IDs and generated numbers. Section 5 names chapter files by slug. Section 7 adds `fmt-docs.sh` to the managed files and `just fmt`. Section 18, from v2, becomes the restructure rules above.
- **Templates:** the PRD, UX and design templates use headings with IDs. The justfile template runs `fmt-docs.sh` from `fmt`.
- **Agents block:** cite IDs such as `D-7kq3`, run `just fmt` after editing headings, and grep a section's ID and its aliases for history.
- **Skills:** `restructure` reduces to moving text, adding aliases and running `just fmt`. The doc skills and `design-review` stop choosing numbers. `audit` and `upgrade` learn the new form.
- **devkit's design:** D3's paragraph on stable IDs, D13 and D20 describe this. D10.18, "IDs that can't collide", is reversed: random IDs are now the choice, and numbered IDs move to Alternatives considered. A new alternative records v2's fixed numbers.
- **devkit's PRD:** R17 adds that reorganizing a doc never breaks a citation, as v2 already does.
- **devkit's own docs** migrate as any project would, which shows the result on a real 600-line design.

## 5. Work

One milestone, done when devkit's own docs are on the new form and `just check` passes.

1. Rework `lint-docs.sh` and its tests for bracketed IDs, numbering order and aliases.
2. Write `fmt-docs.sh` with `--adopt`, with tests for numbering, new IDs, contents and adoption.
3. Rewrite v2's conventions, changelog, templates, agents block and skills.
4. Migrate devkit's PRD and design, and restructure its design into reading order.

## 6. Alternatives considered

### 6.1 Fixed numbers that run out of order

v2 as committed. It needs no new script, but the page shows numbers like 4, 15, 16, 5, which help nobody find their way and look like mistakes.

### 6.2 Renumbering and rewriting citations

A restructure could renumber and rewrite every citation. Code and docs can be rewritten, but commit messages and other repos can't, so history and cross-repo citations would point at the wrong sections.

### 6.3 Names instead of random IDs

C++ standard style stable names, such as `D-retry-backoff`, read well. But a name invites renaming when the section's scope drifts, names get long in code comments, and two sections can want the same name. A random ID has no meaning to drift from.

### 6.4 Sequential IDs

A counter per kind, as IBM DOORS uses, gives short IDs like `D47`. But they still look ordered, and two branches still race for the next one.

### 6.5 Hidden anchors

The ID could go in an invisible `<a id="D-7kq3"></a>` above the heading, keeping headings clean. Readers on GitHub then can't see what to cite, and agents reading raw text see noise either way.

### 6.6 No section numbers

Drop display numbers and rely on the contents and GitHub's outline. It removes the generator, but "see 3.2" is how people talk about a long doc, and numbers help a reader keep their place.

## 7. Open questions

- **Plan IDs.** Milestones are reordered sometimes, and tasks are cited in commits. They could use `M-` IDs too. They are left alone here because the plan is ordered work that gets deleted when done, and "M3" is easy to say. Is that the right line?
- **Per-section aliases after adoption.** Every adopted section gets an `**Also:**` line with its old number, which adds a line to every section. A single table of old to new IDs per doc would be quieter but needs a lookup. Which reads better in practice?
- **Requirement numbers.** Should PRD requirements show list numbers at all, or only their IDs? Numbers help in review discussions, and IDs are what everything cites.
