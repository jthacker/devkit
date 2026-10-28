# Project conventions

The rules every devkit project follows. Their version is in [VERSION](VERSION), what changed between versions in [CHANGELOG.md](CHANGELOG.md), and the files a project starts from in [templates/](templates/).

## 1. The document set

| Doc | Answers | Lifetime |
| --- | --- | --- |
| `docs/prd.md` | What are we building, for whom, and how do we know it worked? | Durable. Built and planned requirements. |
| `docs/ux.md` | How do people experience it? | Durable. Starts with the first interface beyond commands. |
| `docs/design.md` | How does it work, and why this way? | Durable. Built and planned sections. |
| `docs/plan.md`, `docs/plan/M<n>.md` | What is left, in what order? | Durable. Shrinks as work finishes. |
| `docs/ideas.md` | What might we do later? | Durable. Starts with the first idea. |
| `docs/proposals/<slug>.md` | Should we change something, and why? | Deleted once decided. |
| `docs/analyses/<slug>.md` | What did a spike, study, incident or release show? | Permanent evidence. |
| `docs/user/` | How do I use it? | Durable. Only built behavior. |
| `docs/ops/` | How do I run it? | Optional. Runbooks for a project that runs as a service. |
| `docs/dev/` | How do I work on it? | Optional. Only what AGENTS.md and the justfiles don't say. |

Each role has a home. The PRD is the product manager's, `ux.md` the designer's, the design and plan the engineer's, analyses the researcher's, `docs/user/` the writer's and `docs/ops/` the operator's. One person may play every role.

`ux.md` holds user flows as Mermaid diagrams, screens as PNG or SVG images in `docs/ux/`, interaction rules, and the design system where there is one. Each section says in words what its screens show, so a reader doesn't depend on the image. A section whose source lives in a design tool links to it, and the committed image is the decided version. A threat model is an optional Security section in the design.

`docs/README.md` indexes them, one row per doc or folder. Images and other supporting files go in `docs/images/` or a folder named after the doc that uses them.

A project starts with the PRD. The design follows a reviewed PRD, and the plan a reviewed design. `docs/user/` starts with the first behavior a person can use.

## 2. Stable references

Every section of the PRD, `ux.md` and design has an ID that never changes: the doc's name, a hyphen and four characters, such as `prd-4hz8`, `ux-c3pa` or `design-7kq3`. The characters are lowercase Crockford base32, with at least one letter and one digit. Plan milestones and tasks are `M2` and `M2.3`.

The ID sits in an anchor at the end of the section's heading, as in `### 3.2 Retries <a id="design-7kq3"></a>`. In the PRD, each requirement is a numbered item whose bold lead is its title, with its anchor after it. Bulleted items aren't requirements.

```markdown
1. **Edits reach every device.** <a id="prd-4hz8"></a> An edit made offline
   appears on the user's other devices within a minute of reconnecting.
```

- Docs link to a section by its ID, with the section's title as the link text, after the doc's name when the section is in another doc: `[Queue](#design-b6tn)`, `[PRD: Edits reach every device](prd.md#prd-4hz8)`. Words such as "see" go outside the link.
- Code comments cite the bare ID, as in `// Give up after five attempts, design-7kq3.` Analyses cite bare IDs too, since they are never rewritten.
- Commits cite IDs in a `Refs:` trailer (section 17).
- An ID never changes meaning, and is never reused after its section is deleted. A heading may hold extra anchors after its main ID, for sections merged into it or its ID in another doc (section 18). Each ID is defined once.
- An ID in another repo is qualified by that repo's short name, as in `api:design-7kq3` (section 15).

Nobody writes section numbers, IDs or link text by hand. `just fmt` runs `.devkit/fmt-docs.sh`, which numbers every heading of the PRD, `ux.md` and design in reading order and every requirement within its area, gives an ID to any heading or requirement without one, turns bare IDs in docs into links, rewrites each link's text and path to match its target, marking links to planned sections, points links and code citations that name an extra anchor at the main ID, and rewrites the contents list. It leaves analyses alone. So a new section is a plain heading, and a doc may cite a bare ID for `fmt` to link. An author may write a new section's anchor by hand, and `fmt` keeps it if it has the right form and isn't in the repo or its history. New IDs are checked against the history, so `fmt` won't mint them in a shallow clone.

To read a section, grep for its anchor, as in `grep -n 'id="design-7kq3"' docs/design.md`, and read to the next heading. `git log --grep design-7kq3` finds its history, and each extra anchor finds the history of what merged into it. An old ID such as `D4.2` is an extra anchor too, found the same way and never by heading number.

## 3. Lifecycles

Main holds the reviewed state of the whole product process: what is built, what is decided but not built, and what is being considered. Branches hold work no one has reviewed. Git history holds how each part got here.

### 3.1 Proposals are arguments

A proposal argues for an undecided change, such as a feature, rewrite, spike or library switch: the problem, the options and the case for one. It lives in `docs/proposals/` while open, and may be merged to main for wider discussion. Its Dependencies section lists what must be true before the change can start. A change that needs no argument skips the proposal and goes straight to design review.

- **Accepted:** a design review writes it into its final docs (section 3.5) and deletes the file in the same change.
- **Rejected:** its main option goes to the design's Alternatives considered if a reader would wonder about it. The file is deleted, and the commit message says why.

A spike proposal is accepted when the spike is approved. Its results come back as an analysis.

### 3.2 The plan shrinks

The plan holds only what helps decide what to do next. `docs/plan.md` lists the milestones in order, each linking to its file in `docs/plan/`, such as `docs/plan/M5.md`, and holds the requirement coverage, decisions needed and risks. A milestone file holds its goal, its **Done when** result and its tasks. Tasks are checked off as they land, and a finished milestone's file is deleted. Unscheduled ideas and follow-ups go in `docs/ideas.md`, one line each, so the plan holds only scheduled work. An idea leaves that file when a milestone, proposal or design review takes it up, or when it is dropped. There is no `todo.md`, and the plan never names who works on a task.

### 3.3 Analyses are kept

An analysis records evidence: a spike, benchmark, user research, an incident review or an outcome review. It says what was done, what it showed against which pass bars or success criteria, and what it recommends. It is evidence, so it is never rewritten to match later decisions. The design cites it.

An incident review records what happened, the cause and what changes. An outcome review checks the PRD's success criteria after a release, and its recommendations become ideas or proposals.

### 3.4 Done means documented

A milestone is done when `docs/user/` describes the behavior as built, the design and `ux.md` match what was built, the planned markers naming it are removed, and its file is deleted from the plan.

### 3.5 Design review

A decided change is one reviewed change. It writes the PRD, `ux.md` and design into their final wording, marks new or changed sections planned, writes new sections as plain headings that `just fmt` numbers and gives IDs, adds the plan tasks, moves rejected options to Alternatives considered, and deletes the proposal if there is one. Reviewers read the docs as they will be, as a diff against main, so approving it is the decision. After approval the text changes only to remove the planned marker when it ships, or through another design review.

Before merging, a design review is checked against what is new on main. Two reviews that change the same section are a design conflict, and the later one is made against the earlier.

### 3.6 Planned sections

A section decided but not built has a marker naming the milestone that builds it, such as `**Planned:** M5`, as the first line under its heading. Every heading and requirement inside a planned section carries its own marker, so a reader who lands on one by its ID sees it.

A PRD requirement carries it after its anchor, as in `1. **Sync.** <a id="prd-m2c7"></a> **Planned:** M5. Edits reach every device.` A change to a built section is a planned subsection, and the built text stays as it is until the change ships. Overviews, diagrams and tables also show only what is built, and a planned change to one goes in a planned subsection.

`just fmt` adds "(planned)" to the text of each link to a planned section and to its contents entry, so a link from built text doesn't read as built. Once the marker is removed, `just fmt` takes it away.

The marker names a milestone in the plan. `docs/user/` has no markers, since it describes only what is built. Dropping planned work removes its sections, or moves them to Alternatives considered, in a reviewed change.

## 4. Writing style

- Plain, direct sentences in active voice, as an engineer explaining a decision to a peer. No em dashes, parenthetical asides, marketing language, hedging or filler.
- Concrete examples over abstract claims.
- Docs describe the current state of the process, built and planned. Git holds the history, so docs have no changelogs, decision logs, done lists, edit dates or notes such as "previously this said X". The exception is checking off plan tasks during a milestone.
- No time estimates. Say what makes the work hard, and whether it needs research.
- Mark assumptions, and separate what is known from what is guessed.
- Never use a real person's name. Use a placeholder such as `user`.
- Long docs get a contents list and numbered sections, as in `## 1. Problem` and `### 1.1 ...`. In the PRD, `ux.md` and design, `just fmt` keeps both.
- Diagrams are Mermaid code blocks. Images are separate files referenced by relative path, never pasted SVG. Every diagram or image has a one-line caption.
- Keep docs as short as they can be while complete. Agents load them as context.

### 4.1 User-facing text

Text users read is stricter. That covers `docs/user/`, the README and every message the product shows. Each sentence is short and says one thing. No colons, no em dashes and no lists of three.

### 4.2 Sentences and paragraphs

These rules apply to every doc. Section 4.1 adds its limits for text users read.

- One idea per sentence. Split a sentence that joins two claims. Put the main clause first.
- The actor is the subject and the action is the verb. Write "the hook checks the version", not "a check of the version is performed". Avoid opening with "there is" or "it is".
- Start a sentence with what the reader already knows and end it with what is new.
- Call each thing by one name. Define a term where it first appears and don't swap in synonyms for variety. Replace an unclear "it" or "this" with its noun.
- Put a goal or condition before the instruction, as in "To add a section, write a plain heading."
- A paragraph opens with its point, so a reader who reads only first sentences follows the argument. It covers one topic in a few sentences, and each sentence follows from the one before.
- A list holds parallel items or steps, numbered when order matters. Its items share one grammatical form, and a sentence introduces it.

## 5. Size

The PRD, `ux.md` and design are each one file, so an ID's doc name is also its file. An agent loads one section by its ID rather than a whole doc. Past 600 lines, the linter warns about any doc. Move what belongs elsewhere: evidence to an analysis, how-to to `docs/user/`, and long Alternatives considered trimmed. A design that keeps growing may describe a system ready to split into components (section 15).

## 6. Agent instructions

`AGENTS.md` at the root is every agent's entry point. `CLAUDE.md` contains only `@AGENTS.md`.

AGENTS.md has a block between `<!-- devkit:begin conventions=N -->` and `<!-- devkit:end -->` that summarizes these conventions for agents without the plugin. `N` is the version the project follows. Everything outside the block belongs to the project: what it is, its layout, its commands and its own rules.

devkit manages that block, `.devkit/lint-docs.sh`, `.devkit/fmt-docs.sh` and `.devkit/check-commits.sh`. Only devkit's upgrade changes them.

## 7. Tooling

- Every justfile starts with a private `_default` recipe: `@just --justfile {{source_file()}} --list`. `source_file()` makes a module list its own recipes, not the root's.
- Each component has its own justfile with `build`, `test` and `clean`, exposed to the root with `mod`. The root `build`, `test`, `lint` and `check` cover every component, by aggregating them or by running one workspace tool, such as a TypeScript solution build.
- `check` runs `lint` and `test`, and is what CI runs. `lint` checks formatting without changing files, and runs `.devkit/lint-docs.sh` and `.devkit/check-commits.sh`. A build never runs tests.
- `fmt` runs `.devkit/fmt-docs.sh` (section 2) and formats the code in place.
- Where they apply, the root also has:
  - `run *args` runs the project from the checkout.
  - `setup` installs what a fresh checkout needs, such as toolchains and dependencies, and is safe to run again.
  - `install` builds something the user runs on their own machine, such as a CLI, app or plugin, and installs it from the checkout, such as with `cargo install --path` or a copy to `~/.local/bin`. Running it again updates it. Libraries and services deployed elsewhere don't have one.
- `.devkit/lint-docs.sh [root]` checks the docs for em dashes, broken links, links to an anchor a Markdown file doesn't have, docs missing from their index, planned markers naming a milestone the plan doesn't have or sitting in user docs, and headings and requirements inside a planned section without their own marker, and warns about docs past 600 lines. It runs `.devkit/fmt-docs.sh --check`, which changes nothing and fails where `fmt` would change something, where a link or citation in docs or code names an ID that doesn't exist, and where an ID is defined twice. It needs no history, so it runs in a shallow CI checkout.
- Code is every text file git tracks outside `docs/`. Files given the `devkit-examples` attribute in `.gitattributes`, such as test fixtures, aren't checked. In Markdown, IDs in backticks are examples. Qualified IDs such as `api:design-7kq3` aren't checked.
- `.devkit/check-commits.sh [range]` checks the trailers of section 17 on each commit in a git range, by default those not yet on the upstream branch. It skips merges and commits made before it was added.
- Paths in the project never contain spaces.

## 8. Where apps keep data

An app or tool keeps its data, config and state in the OS's standard per-user directories, never in a new folder directly in the home directory. An explicit setting or flag overrides the default. On Linux, use the XDG base directories, falling back to `~/.local/share` and `~/.config`.

People copy these paths into terminals, so they never contain spaces. On macOS that rules out `~/Library/Application Support`, so prefer the XDG data directory. When the only standard location has a space, the design says which location the app uses and why.

## 9. Git

- A solo project develops on `main` and commits to it directly, after the user approves the change.
- A project in team mode says so in `AGENTS.md` outside the managed block. Every change, including a design review, goes through a branch and a reviewed pull request. Branches are current with main before they merge, or merge through a merge queue, so checks run on the merged result. `CODEOWNERS` maps doc paths to the people who review them, such as designers for `docs/ux.md`.
- People who don't use git review pull requests in the browser, or pass feedback to an agent. A commit that resolves feedback says in its body what was raised and how it was resolved.
- A commit holds one change, with its tests and docs, and `just check` passes before it.
- The subject is a short plain sentence, under 72 characters, saying what changed and why, such as `Retry failed syncs so edits survive a dropped connection`. IDs go in the `Refs:` trailer, not the subject. No type prefixes such as `feat:`.
- Every commit ends with trailers: `Refs:` with the IDs it touches, `Change:` naming its kind, and `Changelog:` when users notice it (section 17).
- When the why doesn't fit in the subject, the subject says what changed and a body says why. The body also covers what the diff doesn't show, such as options rejected or effects elsewhere. A change the subject fully explains has no body.
- A project that publishes versions uses semantic versioning, with the version in one place, such as the package manifest. Each release is an annotated tag `v<version>` on `main`, whose message lists the user-visible changes, built from the `Changelog:` trailers since the last tag. There is no CHANGELOG file.

## 10. The README

The README is the project's ad. It tells a reader what the project is, why it is worth their time and how to start. Its parts come in this order.

1. **Summary.** The first line says what the project is and why it is useful.
2. **Why.** What changes for the people who use it, compared with how they work today. Concrete examples beat claims. Each project decides how deep this goes, from a few sentences to worked examples for each kind of user.
3. **Start.** The fewest steps from nothing to using it today, with every command. Point at `just install` when there is one. Before there is anything to use, one line says so.
4. **More.** Links to `docs/user/` once it exists, `docs/README.md`, and `AGENTS.md` for working on it.

How-to detail belongs in `docs/user/`. The README follows section 4.1.

## 11. Tests

- `just test` runs without the network, credentials or the user's real data, using temporary directories. Tests that need more run from their own recipe.
- New or changed behavior comes with tests. Test through public interfaces, so tests survive refactoring.
- A bug fix starts with a test that fails because of the bug.
- Tests live where the stack's tools expect them.
- Never skip, loosen or delete a failing test to get a passing build without the user's agreement.

## 12. Dependencies

- Prefer the standard library and dependencies the project already has. Add one when it replaces substantial or tricky code and is maintained.
- A dependency that shapes the design, such as a framework, database or protocol library, is a design decision. The design section it affects says why, with the alternatives in Alternatives considered.
- Commit lock files. Upgrade dependencies in their own commits.

## 13. Secrets and local config

- Never commit secrets such as keys, tokens and passwords.
- Local settings go in a gitignored `.env` at the root. A committed `.env.example` lists every variable with a placeholder value and a one-line comment.
- Docs, examples and tests use placeholders, never real secrets or personal data.
- A committed secret must be rotated. Removing it from history doesn't make it safe.

## 14. Agent context

An agent needs nothing outside the repo to work at any stage. Everything else in these conventions serves that.

- `AGENTS.md` points to `docs/README.md`, which indexes every doc with a line on what it holds. IDs lead from there to the exact section.
- A built section matches the code, and a planned section says it isn't built, so an agent never guesses which it is reading.
- Commits cite IDs, so `git log --grep design-7kq3` returns a section's history with its reasons. Read it before changing a section.
- Load what the stage needs, not every doc. Building a task reads the task, the planned sections it cites, the built sections they depend on, and the code. Fixing a bug reads the user docs and design for the behavior, incident reviews, and the history of the cited sections.
- Unreviewed work on other branches isn't context. Discussion held outside the repo is input, and its outcome lands in a commit or a doc.

## 15. Products across repos

Keep a product in one repo where possible. When components must live apart, a product repo holds the PRD, `ux.md`, the design of what crosses repos such as contracts between components, cross-repo proposals and outcome reviews. Each component repo keeps a design of its own internals and its own plan.

- A change that crosses repos has one design review, in the product repo. Component repos follow with implementation, and planned sections where their internals change.
- Each repo's `AGENTS.md` has a Related repos section, outside the managed block, listing each related repo's short name, role and clone URL. Clone them to read, and change a repo only from its own checkout.
- A citation of another repo's section is qualified, as in `api:design-7kq3`.
- A product milestone lists tasks per repo, as in `M7.2 (api)`. Its planned markers are removed once the component changes it cites have merged.

## 16. Refactors

A refactor changes how code is built, not what it does.

- ID citations move with the code they describe. One is dropped only when its code is gone.
- Design sections that describe the old structure are updated in the same change. An approach the refactor rules out moves to Alternatives considered.
- A refactor that changes a design section or moves code between components starts as a proposal, unless the design or plan already calls for it.
- If `docs/user/` would change, behavior changed, so it is a task of its own.

## 17. Typed commits

Every commit says what kind of change it is, so each reader can filter history with git alone, and release notes come from the commits.

```text
Retry failed syncs so edits survive a dropped connection

The client gave up after one failed attempt, so offline edits were
dropped when the connection returned mid-sync.

Refs: design-7kq3, M2.3
Change: fixed
Changelog: Edits made offline are no longer lost if the connection drops.
```

- The last paragraph of the message holds the trailers. `Refs:` lists the section and task IDs the commit touches, separated by commas, and is left out when there are none. `Change:` takes one value from the table. A change that is two kinds is two commits.
- `Changelog:` is one sentence for users, following section 4.1. It says what users notice, not what the code does.
- On a squash merge, the squash message keeps the trailers.

| Value | Meaning | Changelog |
| --- | --- | --- |
| `added` | New behavior users see | Required |
| `changed` | Different behavior users see | Required |
| `deprecated` | Behavior that will be removed | Required |
| `removed` | Behavior users relied on is gone | Required |
| `fixed` | A bug users could hit is fixed | Required |
| `security` | A vulnerability is fixed | Required |
| `ops` | Config, deployment or runtime changes operators need | Optional, for operators |
| `docs` | Docs only, including design reviews and proposals | None |
| `internal` | Refactors, tests, build, tooling and dependencies | None |

Filter with `git log --grep '^Change: fixed' v1.2.0..`, and read the notes with `git log --format='%(trailers:key=Changelog,valueonly)' v1.2.0..`.

## 18. Restructuring docs

The PRD, `ux.md` and design can be reorganized as they grow. Restructuring changes where text sits, not what it says. A change to what a section says is a design review. Each move is an edit to the text followed by `just fmt`, which renumbers the headings and contents and fixes the links.

- **Reorder.** Move the text. IDs and links stay as they were.
- **Merge.** One section's ID survives, usually the one cited most, even if the merged section gets a new title. A merge never mints an ID. The heading keeps the absorbed ID as an extra anchor, as in `### 2.1 Retries <a id="design-7kq3"></a><a id="design-b6tn"></a>`, and `fmt` points links and code citations at the surviving ID. Subsections keep their IDs wherever they move.
- **Split.** The original ID stays with the part that keeps its main meaning, and `fmt` gives the new part an ID. Update by hand the links and citations whose meaning moved, in the same commit.
- **Promote or demote.** The ID moves with the section, so only numbers change.
- **Delete.** Delete the section, leaving no anchor elsewhere. In the same commit, fix each link and citation the linter names: point it at the section that now covers it, or remove it with the code that needed it. Dropped planned work moves to Alternatives considered with its anchor if a reader would wonder about it.
- **Move to another doc.** `fmt` gives the section that doc's ID and keeps its old ID as an extra anchor, then points links and code citations at the new ID. An ID naming another doc is allowed only as an extra anchor.

A restructure is one commit with `Change: docs`. Its `Refs:` names every ID involved, and its body says what merged, moved and was deleted, such as `Merged design-b6tn into design-7kq3`.

## 19. Open questions

The PRD, `ux.md`, design and proposals end with their open questions. Each is a list item that starts with its number and a short title, as in `- **Q2. Retries.** Should a failed sync retry, and what would show it?`, so people can name it in discussion. A new question takes the next number. A number names a question only within its doc and only for now, so the rest may be renumbered when one is settled. Name another doc's question with the doc, as in design Q2, and never cite one in code or commits.

## 20. Decisions

When a decision is the user's, such as an open question, a choice between options, or code and docs that disagree, the agent takes each question on its own:

1. Research it just before asking, since earlier answers can change it. Read the docs, analyses, `git log --grep` on the cited IDs, and the code. Search the web only when the answer turns on outside facts, such as a library's limits or a platform's behavior.
2. Say briefly what was found and where.
3. Give the options with their pros and cons. Recommend one with the reason when one is better. When none is, say so rather than forcing one. When only evidence can settle it, offer a spike.
4. Ask for one answer, the recommended option first. The user can also defer it or answer otherwise. Where the agent has a tool for structured questions, use it.

Ask first the questions others depend on. No question is settled without the user, and one left unanswered stays open. A fact only the user knows, such as where a project lives, is asked plainly, together with the others. Approving a diff stays one approval.
