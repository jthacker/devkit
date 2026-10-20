# Project conventions

The rules every devkit project follows. Their version is in [VERSION](VERSION), what changed between versions in [CHANGELOG.md](CHANGELOG.md), and the files a project starts from in [templates/](templates/).

## 1. The document set

| Doc | Answers | Lifetime |
| --- | --- | --- |
| `docs/prd.md` | What are we building, for whom, and how do we know it worked? | Durable. Built and planned requirements. |
| `docs/ux.md` | How do people experience it? | Durable. Starts with the first interface beyond commands. |
| `docs/design.md` | How does it work, and why this way? | Durable. Built and planned sections. |
| `docs/plan.md`, `docs/plan/M<n>.md` | What is left, in what order? | Durable. Shrinks as work finishes. |
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

Docs and code cite each other by IDs that don't change when text moves: `R3.2` for requirements in the PRD, `U3.2` for sections of `ux.md`, `D4.2` for design sections, and `M2.3` for plan milestones and tasks. Code comments, commits and docs use them, as in `// Retry with backoff, D8.3`.

An ID never changes meaning and never leaves its doc. A number is a label, not a position, so sections may sit in any order. New sections take the next free number at their level. A merged, moved or removed section's ID is kept as an alias (section 18). Each ID is defined once, live or as an alias. When a change on a branch takes a number that main took first, renumber it on rebase, since nothing on main cites it yet. An ID in another repo is qualified by that repo's short name, as in `api:D4.2` (section 15).

## 3. Lifecycles

Main holds the reviewed state of the whole product process: what is built, what is decided but not built, and what is being considered. Branches hold work no one has reviewed. Git history holds how each part got here.

### 3.1 Proposals are arguments

A proposal argues for an undecided change, such as a feature, rewrite, spike or library switch: the problem, the options and the case for one. It lives in `docs/proposals/` while open, and may be merged to main for wider discussion. Its Dependencies section lists what must be true before the change can start. A change that needs no argument skips the proposal and goes straight to design review.

- **Accepted:** a design review writes it into its final docs (section 3.5) and deletes the file in the same change.
- **Rejected:** its main option goes to the design's Alternatives considered if a reader would wonder about it. The file is deleted, and the commit message says why.

A spike proposal is accepted when the spike is approved. Its results come back as an analysis.

### 3.2 The plan shrinks

The plan holds only what helps decide what to do next. `docs/plan.md` lists the milestones in order, each linking to its file in `docs/plan/`, such as `docs/plan/M5.md`, and holds the requirement coverage, decisions needed, risks and Later. A milestone file holds its goal, its **Done when** result and its tasks. Tasks are checked off as they land, and a finished milestone's file is deleted. Unscheduled ideas go under Later. There is no `todo.md`, and the plan never names who works on a task.

### 3.3 Analyses are kept

An analysis records evidence: a spike, benchmark, user research, an incident review or an outcome review. It says what was done, what it showed against which pass bars or success criteria, and what it recommends. It is evidence, so it is never rewritten to match later decisions. The design cites it.

An incident review records what happened, the cause and what changes. An outcome review checks the PRD's success criteria after a release, and its recommendations become ideas or proposals.

### 3.4 Done means documented

A milestone is done when `docs/user/` describes the behavior as built, the design and `ux.md` match what was built, the planned markers naming it are removed, and its file is deleted from the plan.

### 3.5 Design review

A decided change is one reviewed change. It writes the PRD, `ux.md` and design into their final wording, marks new or changed sections planned, takes the next free R, U and D numbers, adds the plan tasks, moves rejected options to Alternatives considered, and deletes the proposal if there is one. Reviewers read the docs as they will be, as a diff against main, so approving it is the decision. After approval the text changes only to remove the planned marker when it ships, or through another design review.

Before merging, a design review is checked against what is new on main. Two reviews that change the same section are a design conflict, and the later one is made against the earlier.

### 3.6 Planned sections

A section decided but not built has a marker naming the milestone that builds it, as the first line under its heading:

```markdown
## 15. Sync engine

**Planned:** M5
```

A PRD requirement carries it after its title, as in `- **R10. Sync.** **Planned:** M5. Edits reach every device.` A change to a built section is a planned subsection, and the built text stays as it is until the change ships.

The marker names a milestone in the plan. `docs/user/` has no markers, since it describes only what is built. Dropping planned work removes its sections, or moves them to Alternatives considered, in a reviewed change.

## 4. Writing style

- Plain, direct sentences in active voice, as an engineer explaining a decision to a peer. No em dashes, parenthetical asides, marketing language, hedging or filler.
- Concrete examples over abstract claims.
- Docs describe the current state of the process, built and planned. Git holds the history, so docs have no changelogs, decision logs, done lists, edit dates or notes such as "previously this said X". The exception is checking off plan tasks during a milestone.
- No time estimates. Say what makes the work hard, and whether it needs research.
- Mark assumptions, and separate what is known from what is guessed.
- Never use a real person's name. Use a placeholder such as `user`.
- Long docs get a table of contents and numbered sections: `## 1. Problem`, `### 1.1 ...`.
- Diagrams are Mermaid code blocks. Images are separate files referenced by relative path, never pasted SVG. Every diagram or image has a one-line caption.
- Keep docs as short as they can be while complete. Agents load them as context.

### 4.1 User-facing text

Text users read is stricter. That covers `docs/user/`, the README and every message the product shows. Each sentence is short and says one thing. No colons, no em dashes and no lists of three.

## 5. Size

A doc past 600 lines splits by chapter. Its file keeps the title, contents and section 1. Every other top-level section moves to its own file in a folder named after the doc, keeping its number, so section 4 of `docs/design.md` becomes `docs/design/4-architecture.md`. The contents links to each chapter, and IDs such as `D4.4` keep their meaning. New chapters in a split doc get their own files.

## 6. Agent instructions

`AGENTS.md` at the root is every agent's entry point. `CLAUDE.md` contains only `@AGENTS.md`.

AGENTS.md has a block between `<!-- devkit:begin conventions=N -->` and `<!-- devkit:end -->` that summarizes these conventions for agents without the plugin. `N` is the version the project follows. Everything outside the block belongs to the project: what it is, its layout, its commands and its own rules.

devkit manages that block, `.devkit/lint-docs.sh` and `.devkit/check-commits.sh`. Only devkit's upgrade changes them.

## 7. Tooling

- Every justfile starts with a private `_default` recipe: `@just --justfile {{source_file()}} --list`. `source_file()` makes a module list its own recipes, not the root's.
- Each component has its own justfile with `build`, `test` and `clean`, exposed to the root with `mod`. The root `build`, `test`, `lint` and `check` cover every component, by aggregating them or by running one workspace tool, such as a TypeScript solution build.
- `check` runs `lint` and `test`, and is what CI runs. `lint` checks formatting without changing files, and runs `.devkit/lint-docs.sh` and `.devkit/check-commits.sh`. A build never runs tests.
- Where they apply, the root also has:
  - `fmt` formats the code in place.
  - `run *args` runs the project from the checkout.
  - `setup` installs what a fresh checkout needs, such as toolchains and dependencies, and is safe to run again.
  - `install` builds something the user runs on their own machine, such as a CLI, app or plugin, and installs it from the checkout, such as with `cargo install --path` or a copy to `~/.local/bin`. Running it again updates it. Libraries and services deployed elsewhere don't have one.
- `.devkit/lint-docs.sh` checks the docs for em dashes, docs past 600 lines, broken links, docs missing from their index, R, U and D citations to sections that don't exist or that cite an alias, IDs defined twice, IDs that were defined at the base commit and are now gone, and planned markers naming a milestone the plan doesn't have or sitting in user docs. IDs in backticks count as examples, and qualified IDs such as `api:D4.2` aren't checked.
- `.devkit/lint-docs.sh [root [base]]` takes the base commit for the check on gone IDs. It defaults to the upstream branch, or `HEAD` without one. CI on a pull request passes the target branch.
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
- The subject is a short plain sentence, under 72 characters, saying what changed and why, citing IDs, such as `Retry failed syncs so edits survive a dropped connection, D8.3`. No type prefixes such as `feat:`.
- Every commit ends with a `Change:` trailer naming its kind, and a commit users notice also has a `Changelog:` trailer (section 17).
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
- Commits cite IDs, so `git log --grep D7.3` returns a section's history with its reasons. Read it before changing a section.
- Load what the stage needs, not every doc. Building a task reads the task, the planned sections it cites, the built sections they depend on, and the code. Fixing a bug reads the user docs and design for the behavior, incident reviews, and the history of the cited sections.
- Unreviewed work on other branches isn't context. Discussion held outside the repo is input, and its outcome lands in a commit or a doc.

## 15. Products across repos

Keep a product in one repo where possible. When components must live apart, a product repo holds the PRD, `ux.md`, the design of what crosses repos such as contracts between components, cross-repo proposals and outcome reviews. Each component repo keeps a design of its own internals and its own plan.

- A change that crosses repos has one design review, in the product repo. Component repos follow with implementation, and planned sections where their internals change.
- Each repo's `AGENTS.md` has a Related repos section, outside the managed block, listing each related repo's short name, role and clone URL. Clone them to read, and change a repo only from its own checkout.
- A citation of another repo's section is qualified, as in `api:D4.2`.
- A product milestone lists tasks per repo, as in `M7.2 (api)`. Its planned markers are removed once the component changes it cites have merged.

## 16. Refactors

A refactor changes how code is built, not what it does.

- ID citations move with the code they describe. One is dropped only when its code is gone.
- D sections that describe the old structure are updated in the same change. An approach the refactor rules out moves to Alternatives considered.
- A refactor that changes a D section or moves code between components starts as a proposal, unless the design or plan already calls for it.
- If `docs/user/` would change, behavior changed, so it is a task of its own.

## 17. Typed commits

Every commit says what kind of change it is, so each reader can filter history with git alone, and release notes come from the commits.

```text
Retry failed syncs so edits survive a dropped connection, D8.3

The client gave up after one failed attempt, so offline edits were
dropped when the connection returned mid-sync.

Change: fixed
Changelog: Edits made offline are no longer lost if the connection drops.
```

- The last paragraph of the message holds the trailers. `Change:` takes one value from the table. A change that is two kinds is two commits.
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

The PRD, `ux.md` and design can be reorganized as they grow. Sections merge, split, move between chapters or change order, and chapters are added. Restructuring changes where text sits, not what it says. A change to what a section says is a design review.

Every ID survives a restructure, since code, commits and other repos cite it. The section that takes over an ID's text lists it on an `**Also:**` line under its heading, after any planned marker:

```markdown
### 4.2 Sync

**Also:** D6.1, D6.3
```

- **Reorder.** Move the text. Numbers stay, and the contents lists sections in reading order.
- **Merge.** One section keeps its ID, and the others become its aliases.
- **Split.** The original ID stays with the part that keeps its main meaning. Other parts take the next free numbers.
- **Promote or demote.** The section takes the next free number at its new level and lists its old ID. An alias covers its subsections, so with `**Also:** D4.3` under section 9, `D4.3.2` means `D9.2`.
- **Remove.** Built text that is gone leaves its ID as an alias of the section closest in meaning. Dropped planned work moves to Alternatives considered, which lists its ID.

Docs cite current IDs. Code and commits may keep citing aliases, except where a split moved the meaning to a new section. `git log --grep` finds a section's history under its ID and each alias. The restructure is one commit with `Change: docs`, whose body maps each old ID to its new one.
