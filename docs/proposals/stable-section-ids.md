# Proposal: Section IDs that don't depend on position

- **Status:** draft

Give each section of the PRD, UX doc and design a short ID that names its doc and never changes, such as `design-7kq3`, and generate the section numbers readers see. Docs link to sections by ID, with the section's title as the link text, so references read naturally and a reorder changes nothing but the headings it moves. Code and commits cite the bare ID, which keeps working however the docs are reorganized.

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
- References between docs read naturally and can be clicked.
- Reordering, merging, splitting or promoting sections, or moving them to another doc, keeps every reference and citation working.
- Every ID is a full address. `design-7kq3` is always at `docs/design.md#design-7kq3`, so a link to it can be built anywhere without a search.
- Removing a section makes the lint name every reference and citation still pointing at it.
- A reorder changes only the headings and contents list of the doc it reorders, so it doesn't conflict with other branches' edits elsewhere.
- An ID says which doc it belongs to, so a reader of code knows what it is and where to look.
- IDs stay short enough to cite in a code comment, and imply no order.
- Two branches can add sections without colliding.
- Adding a section stays as easy as writing a heading.

### 2.2 Non-goals

- GitHub's own heading anchors, which come from heading text and change when numbers do. Links use the ID anchors instead.
- Plan IDs. Milestones and tasks keep `M3` and `M3.2`, as section 7 discusses.
- CONVENTIONS.md's own numbered sections. devkit's scripts and skills cite them by number, which has the same problem, but they are devkit's internals rather than a project doc.
- Rewriting history. Old commits keep citing old IDs, which still resolve.

## 3. Dependencies

- **v2 is unpublished.** Conventions v2, which adds fixed numbers and aliases (D20), devkit's upgrade to it and this proposal are on local main and not pushed. No project has v2, so if this proposal is accepted, the design review replaces v2's content in new commits instead of adding v3, and v2 is first pushed in its new form. Met while main stays unpushed. To keep a backup in the meantime, push main to another branch name.

## 4. Proposal

### 4.1 What a reader sees

A design doc renders as numbered sections, with references written as the titles of the sections they point at:

> **3.2 Retries**
>
> **Planned:** M4
>
> A failed sync retries with backoff, up to five attempts (PRD: Edits reach every device). Edits wait in the queue until the server confirms them (see Queue).

Each reference is a link. Clicking it goes to that section, in this doc or another. Nothing on the page is an ID.

### 4.2 What the source looks like

The same section in markdown:

```markdown
### 3.2 Retries <a id="design-7kq3"></a>

**Planned:** M4

A failed sync retries with backoff, up to five attempts
([PRD: Edits reach every device](prd.md#prd-4hz8)). Edits wait in the
queue until the server confirms them (see [Queue](#design-b6tn)).
```

- **The heading** ends with an anchor holding the section's ID. Renderers such as GitHub and VS Code don't show it, and it doesn't depend on the heading text.
- **A reference** is a link to the ID. Its text is the target's title, after the doc's name when the target is in another doc: "Queue", "PRD: Edits reach every device", "UX: Sign in". Words such as "see" go outside the link.
- **Titles, not numbers.** A title changes only when someone renames the section, while a number changes whenever anything above it moves. With titles, a reorder renumbers one doc's headings and contents list and touches no other line, so a design review's diff shows the decision and not a wave of renumbered links. A title also tells a reader more than "§3.1", and rewriting one never changes what a sentence says about order. Numbers stay in headings, so a reader can find their way and say "see 3.2" aloud.

Titles stay short, as headings should, so references don't crowd a sentence. Renaming a section rewrites every link to it, which shows reviewers where the section is used.

A whole design doc:

```markdown
# Notes: Design

1. [Overview](#design-q2m8)
2. [Storage](#design-k9vd)
3. [Sync](#design-r3wq)
4. [Alternatives considered](#design-w5jh)

## 1. Overview <a id="design-q2m8"></a>

Notes keeps every edit on the device first and syncs in the background
([PRD: Sync](prd.md#prd-m2c7)).

## 2. Storage <a id="design-k9vd"></a>

## 3. Sync <a id="design-r3wq"></a>

### 3.1 Queue <a id="design-b6tn"></a>

### 3.2 Retries <a id="design-7kq3"></a>

## 4. Alternatives considered <a id="design-w5jh"></a>
```

Every heading below the title is numbered and has an ID, in the PRD, UX doc and design alike.

The PRD keeps the template's chapters, with requirements in the Requirements chapter. Each area is a heading, and each requirement is a numbered list item whose bold lead is its title, with its anchor after the title:

```markdown
## 5. Requirements <a id="prd-c8x2"></a>

### 5.1 Sync <a id="prd-m2c7"></a>

1. **Edits reach every device.** <a id="prd-4hz8"></a> An edit made offline
   appears on the user's other devices within a minute of reconnecting.
2. **Conflicts never lose text.** <a id="prd-9tqe"></a> When two devices
   edit the same note, both versions are kept.
```

A numbered item with a bold lead is a requirement, anywhere in the PRD. Bulleted items are not, so the bold-led bullets in Problem or Non-goals get no IDs. A planned requirement carries its marker after the anchor.

Plan tasks and proposals refer to sections with the same links, such as `[Design: Retries](../design.md#design-7kq3)`.

### 4.3 Code and commits

Code cites the bare ID:

```go
// Give up after five attempts so a dead server can't drain the battery,
// design-7kq3.
const maxAttempts = 5
```

The doc name in the ID says which file to open, since each doc is one file (section 4.6). It works the same in any language's comments, since it is plain text, and nothing has to rewrite code when sections are reordered.

Commits cite IDs in a `Refs:` trailer, so subjects say what changed in words:

```text
Retry failed syncs with backoff so edits survive a dropped link

Refs: design-7kq3, prd-4hz8
Change: fixed
Changelog: Edits made offline are no longer lost if the connection drops.
```

`git log --grep` finds trailers as it finds subjects. Every form contains the same ID, so `git grep design-7kq3` finds the code and docs about a section, and `git log --grep design-7kq3` finds its commits, wherever it has moved. To find a section's ID, read its heading in the source, or copy it from any link that points there. Agents read the source, so they see IDs directly.

Outside the repo, in a pull request, issue or chat, relative links don't work, so a full link is built from the ID, as in `https://github.com/<owner>/<repo>/blob/main/docs/design.md#design-7kq3`. On GitHub plans that have them, an autolink per doc, such as prefix `design-` pointing at `.../blob/main/docs/design.md#design-<num>`, turns every bare ID in commits, pull requests and issues into that link. These links break only if the section later moves to another doc.

### 4.4 The ID

An ID is the doc's name, a hyphen, and four characters: `prd-4hz8` for a requirement, `ux-c3pa` for a UX section, `design-7kq3` for a design section.

- **The doc name** replaces the R, U and D letters. Out of context, `design-7kq3` says what it points at, where `D-7kq3` means nothing to someone who doesn't know devkit. Other repos' IDs are qualified the same way, as in `api:design-7kq3`.
- **The same string** is the anchor, the link fragment, the code citation and the commit citation. It uses only letters, digits and a hyphen, so no comment syntax, shell, URL, YAML or chat tool treats it specially.
- **Characters** are lowercase Crockford base32, which leaves out `i`, `l`, `o` and `u` so no two look alike. Each ID has at least one letter and one digit, so none reads as a word or a year.
- **There are about 800,000** per kind. New IDs are checked against every ID in the repo and its git history, so a clash can only happen between two branches adding sections at once, and the linter catches it on merge.
- **An ID is never reused**, even after its section is deleted, so an old commit never points at the wrong section.

Four characters is the shortest that keeps cross-branch clashes rare in a doc with hundreds of sections, while staying easy to type and read aloud. The pattern `(prd|ux|design)-[0-9a-z]{4}`, with a letter and a digit required and no letter, digit or hyphen on either side, matches no ordinary words or years, such as `design-time` or `ux-2025-redesign`, so grep and the linter find citations in code without false hits.

### 4.5 `just fmt` does the bookkeeping

Nobody writes a number or a link's text by hand. A new script, `.devkit/fmt-docs.sh`, run by `just fmt`:

1. Numbers every heading in the PRD, UX doc and design in reading order, and every requirement within its area.
2. Gives a fresh ID to any heading or requirement that lacks one.
3. Turns each bare ID in a doc into a link, and rewrites every link's text to its target's title and its path to its target's doc.
4. Rewrites links and code citations that name an extra anchor to the section's main ID.
5. Rewrites the contents list.

Adding a section is writing a plain heading:

```markdown
### Conflict resolution

Two edits to the same note are both kept (design-7kq3).
```

After `just fmt`:

```markdown
### 3.3 Conflict resolution <a id="design-h8fm"></a>

Two edits to the same note are both kept ([Retries](#design-7kq3)).
```

So an agent or person can write a bare ID anywhere in a doc, and `fmt` makes it a readable link.

An author may also write a new section's anchor by hand, as in `<a id="design-h8fm"></a>`, so one edit can add several sections that link to each other, and plan tasks that cite them, without stopping to run `fmt`. `fmt` keeps a hand-written ID if it has the right form and isn't in the repo or its history, and replaces it otherwise.

Minting needs the whole history, so in a shallow clone `fmt` refuses to mint IDs and says why. `fmt-docs.sh --check` changes nothing and mints nothing, and exits non-zero when `fmt` would change something. The linter runs it, so the two never disagree, and it works in a shallow CI checkout.

Analyses are never rewritten, so `fmt` leaves them alone and doesn't turn their bare IDs into links. An analysis cites the bare ID, which stays findable wherever its section moves, where a link would name a doc the section may later leave.


### 4.6 One file per doc

The PRD, UX doc and design are each always one file. Docs are no longer split by chapter, so an ID's doc name is also its file, and every link built from an ID keeps working however the doc is reorganized.

Splitting served two purposes, and both are covered without it:

- **Agent context.** An agent loads only what its task needs by ID: `grep -n 'id="design-7kq3"'` gives the line, and it reads to the next heading. That is narrower than a chapter file.
- **Fewer conflicts in team mode.** Git merges by line, so two people editing different sections of one file merge cleanly. The numbering race is gone with random IDs, and the contents list is regenerated, so a conflict there is resolved by running `fmt` again.

Size is still worth watching, since people read these docs too. Past 600 lines the linter warns instead of failing, and the doc skills look for content that belongs elsewhere: evidence in an analysis, how-to in the user docs, or Alternatives considered trimmed. A design that keeps growing past that usually describes a system ready to split into components, each with its own repo and docs (CONVENTIONS section 15). That is a design decision, not a file layout.

### 4.7 Restructuring

Each move is an edit to the text followed by `just fmt`. Starting from the design in section 4.2:

**Reorder.** Move Sync above Storage. The headings and contents list now say 2, 2.1, 2.2 and 3. The IDs and every link elsewhere stay as they were.

```markdown
## 2. Sync <a id="design-r3wq"></a>
### 2.1 Queue <a id="design-b6tn"></a>
### 2.2 Retries <a id="design-7kq3"></a>
## 3. Storage <a id="design-k9vd"></a>
```

**Merge.** Fold Queue into Retries. One section's ID survives, usually the one with more citations, even if the merged section gets a new title. A merge never mints a new ID. The surviving heading keeps the absorbed ID as an extra anchor:

```markdown
### 2.1 Retries <a id="design-7kq3"></a><a id="design-b6tn"></a>

Edits wait in a local queue until the server confirms them. A failed sync
retries with backoff.
```

The extra anchor keeps the absorbed section's history findable from the merged one, since commits citing `design-b6tn` turn up when grepping the merged section's IDs. Old links in the same file still land in the right place. A merge keeps the meaning, so `fmt` rewrites links in docs and citations in code from `design-b6tn` to `design-7kq3`.

Combining chapters is the same. Subsections keep their IDs wherever they move, since IDs don't encode the hierarchy. Only the old chapter heading's ID becomes an extra anchor on its new parent.

**Split.** The original ID stays with the part that keeps the main meaning. The new part gets a new ID from `fmt`. Links and citations whose meaning moved to the new part are updated by hand in the same commit, since only a person can tell which part each one meant. The commit's `Refs:` trailer names both IDs, so `git log --grep` on the new ID finds the split, whose body names the ID that holds the earlier history.

**Promote or demote.** Turn Retries into its own chapter. Its ID moves with it, so only numbers change.

**Delete.** Delete the section. It leaves no tombstone and no anchor elsewhere. Any link or citation still pointing at it fails the lint:

```text
src/offline/cache.go:8: cites design-p2x9, which doesn't exist
```

Each one is fixed in the same commit: pointed at the section that now covers it, or removed with the code that needed it. Commits keep citing `design-p2x9`, and `git log --grep design-p2x9` still shows why the section existed and when it went. The deleted text is in the commit that removed it. Dropped planned work moves to Alternatives considered with its anchor if a reader would wonder about it, and is deleted otherwise.

**Move to another doc.** A flow that moves from the design into the UX doc gets a new `ux-` ID, so its ID names the doc it is in. Its old ID stays as an extra anchor, and `fmt` rewrites links in docs to the new ID and file, and code citations to the new ID. An ID naming another doc is allowed only as an extra anchor.

```markdown
### 3.4 Sign in <a id="ux-k2rf"></a><a id="design-m8wd"></a>
```

Links from outside the repo name a doc, so they break when their section moves to another doc. Bare IDs don't, which is why code, commits and analyses use them.

The commit body lists what merged, moved and was deleted, so history is easy to follow:

```text
Fold the sync queue into retries, since one can't change without the other

Restructure only. Merged design-b6tn into design-7kq3. Moved design-r3wq
before design-k9vd.

Refs: design-7kq3, design-b6tn, design-r3wq
Change: docs
```

### 4.8 What the linter checks

`lint-docs.sh` runs `fmt-docs.sh --check`, and also fails on mistakes `fmt` can't fix:

```text
docs/design.md:14: heading 3.4 is out of sequence; run just fmt
docs/design.md:22: heading has no ID; run just fmt
docs/plan/M4.md:8: link says Queue but design-b6tn is titled Sync queue; run just fmt
docs/ux.md:31: links design-b6tn, which is now design-7kq3; run just fmt
docs/prd.md:18: links prd-zz99, which doesn't exist
docs/design.md:40: defines design-7kq3, which is already defined
docs/ux.md:12: section's main ID design-m8wd names another doc; give it a ux ID with just fmt
src/sync/queue.go:4: cites design-zz99, which doesn't exist
src/sync/retry.go:9: cites design-b6tn, which is now design-7kq3; run just fmt
```

Today the linter leaves code to `audit`, since identifiers such as `R2` mean other things in code (D13). The new IDs can't be mistaken for anything else, so the linter checks citations in code too. Code is every text file git tracks outside `docs/`. Files given the `devkit-examples` attribute in `.gitattributes` are skipped, so test fixtures, vendored code and docs about the conventions can hold example IDs. In markdown, IDs in backticks are examples, as today.

### 4.9 Moving existing projects

The v1 to v2 migration first joins a split doc back into one file, its top file followed by its chapter files in contents order, and shows the result before going on. Then it runs `fmt-docs.sh --adopt`, which gives each section a new ID, keeps the old number as a second anchor, and turns references in docs into links:

Before:

```markdown
### 4.2 Retries

Up to five attempts, R1.2.
```

After:

```markdown
### 4.2 Retries <a id="design-7kq3"></a><a id="D4.2"></a>

Up to five attempts ([PRD: Edits reach every device](prd.md#prd-4hz8)).
```

It also turns the PRD's `**R1.2**` items into numbered requirements.

Citations in code are rewritten too, and this step isn't optional. Once the docs are reordered, heading 4.2 may be a different section, and a reader who sees `D4.2` in code would open the wrong one. `--adopt` can't tell a citation from an identifier such as `R2`, so it lists every match of the old ID pattern, and the upgrade skill rewrites those that are citations and leaves the rest, reviewed as one diff.

Commits keep their old IDs. The agents block says an old-style ID such as `D4.2` is found by grepping for its anchor, `id="D4.2"`, never by reading heading numbers. A doc citing an old ID fails the lint with the new ID to use, as citing an alias does today. After that, the project can reorder freely, and the numbers stay right.

### 4.10 Docs this changes

- **CONVENTIONS.md:** section 2 describes IDs, anchors, title links and generated numbers. Section 5 drops splitting by chapter: each doc is one file, and past 600 lines the linter warns and the doc skills look for content to move or cut. Section 7 adds `fmt-docs.sh` to the managed files and `just fmt`. Section 9 puts IDs in a `Refs:` trailer. Section 18, from v2, becomes the restructure rules above.
- **Templates:** the PRD, UX and design templates use anchored headings and linked references, and the PRD template numbers requirements within their areas. The justfile template runs `fmt-docs.sh` from `fmt`.
- **Agents block:** cite bare IDs in code and in a commit's `Refs:` trailer, write references in docs as bare IDs or links, run `just fmt` after editing docs or moving sections, grep a section's ID and its extra anchors for history, and find an old-style ID by its anchor.
- **Skills:** `restructure` reduces to moving text, keeping anchors and running `just fmt`. The doc skills and `design-review` stop choosing numbers. `audit` and `upgrade` learn the new form, and `upgrade` rewrites old citations in code.
- **devkit's design:** D3's paragraph on stable IDs, D13 and D20 describe this. D13 gains the check of citations in code and the `--check` mode, and its size check becomes a warning. D3's row for the design and D16.3 drop splitting by chapter, which team projects did from the start. D10.18, "IDs that can't collide", is reversed: random IDs are now the choice, and numbered IDs move to Alternatives considered. A new alternative records v2's fixed numbers.
- **devkit's PRD:** R17 adds that reorganizing a doc never breaks a citation, as v2 already does.
- **devkit's own docs** migrate as any project would, which shows the result on a real 600-line design.

## 5. Work

One milestone, done when devkit's own docs are on the new form and `just check` passes.

1. Rework `lint-docs.sh` and its tests to run `fmt-docs.sh --check` and to check citations in code, honoring `devkit-examples`.
2. Write `fmt-docs.sh` with `--check` and `--adopt`, with tests for numbering, requirements, minted and hand-written IDs, refusing to mint in a shallow clone, title links, contents, link paths after a move to another doc, code rewrites after a merge or move, and adoption, including joining a split doc.
3. Check on a scratch repo that GitHub and VS Code render the anchors and follow links within and between docs, and that a GitHub autolink opens the section.
4. Rewrite v2's conventions, changelog, templates, agents block and skills.
5. Migrate devkit's PRD and design, rewrite their citations in code, and restructure the design into reading order.

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

Reads as "this section of the design", like the links in docs. But `#` means something to chat tools, issue trackers and markdown at the start of a line.

### 6.6 A tool prefix: `devkit:D-7kq3`

Says which system the ID belongs to, but not which doc. It is long, and it clashes with the `api:` qualifier for other repos.

### 6.7 Names instead of random IDs

Stable names, as the C++ standard uses, such as `design-retry-backoff`, read well. But a name invites renaming when the section's scope drifts, names get long in code comments, and two sections can want the same name. A random ID has no meaning to drift from.

### 6.8 Sequential IDs

A counter per kind, as IBM DOORS uses, gives short IDs like `design-47`. But they still look ordered, and two branches still race for the next one.

### 6.9 Keeping every deleted ID

v2 keeps a deleted section's ID as an anchor on the section closest in meaning, and fails the lint when an ID defined at the base commit is gone. With numbered IDs that stopped a number being reused. Random IDs are checked against history, so they aren't reused, and the rule only forces anchors onto sections they don't belong to. Citations to a deleted section are caught anyway, since they name an ID that doesn't exist. What's lost is a guard for a merge that forgets its extra anchor when nothing cites the absorbed ID. The commit body still records the merge.

### 6.10 No section numbers

Links already show titles, so headings could drop numbers too. References would read the same, but a long doc is hard to find one's way in without numbers, and "see 3.2" is how people talk about one.

### 6.11 Numbers as link text

References could read "§3.2" and "PRD §1.2", which is short and familiar. But every reorder would rewrite the text of every link to a moved section, in every doc, plan file and proposal. A design review that adds an early chapter would show hundreds of changed lines and conflict with every other open review. Sentences about order, such as "the sections after §3", would quietly change meaning when rewritten.

### 6.12 Paths in code citations

Code could cite `docs/design.md#design-7kq3`, which tells a reader which file to open, and some editors open it there. But the path repeats what the doc name in the ID already says, goes stale when a section moves to another doc, so `fmt` would have to rewrite code on every such move, and few editors open the section rather than the file.

### 6.13 IDs in commit subjects

v1 cites IDs in the subject, where `git log --oneline` shows them. A random ID is 11 characters, a sixth of the 72-character limit, and two or three crowd out what changed.

### 6.14 Split docs

Docs past 600 lines could keep splitting into one file per chapter, as v1 does. Then an ID names a doc but not a file, so links from outside the repo, autolinks and editor tools need a search to find the section, and break when it moves between chapter files. `fmt` would also have to name chapter files, order them and rewrite link paths. Reading by ID gives agents the narrow context splitting was for, and git merges edits to different sections of one file cleanly.

## 7. Open questions

- **Copying an ID from the rendered page.** A person reading on GitHub sees no IDs, and the link icon by a heading copies GitHub's slug, which changes with the number. Reviewers who don't use git (R13) will cite what they can copy. Is a short note in the agents block and user guide enough, or should each heading show a small link to its ID?
- **Plan IDs.** Milestones are reordered sometimes, and tasks are cited in commits. They could use IDs and links too. They are left alone here because the plan is ordered work that gets deleted when done, and "M3" is easy to say. But `M2.3` in code can't be checked, for the reason in section 6.4. Is that the right line?
