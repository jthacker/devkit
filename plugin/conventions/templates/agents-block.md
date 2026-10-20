<!-- devkit:begin conventions={{VERSION}} -->
## Docs

This project follows the devkit conventions, version {{VERSION}}. Only devkit's upgrade edits this block and `.devkit/`.

- `docs/README.md` indexes the docs: `prd.md` says what to build and why, `ux.md` how people experience it, `design.md` how it works, `plan.md` and `plan/` what is left. Read the design before changing behavior, and `git log --grep` a section's ID and its `**Also:**` aliases for why it is that way.
- Cite requirements, UX and design sections and plan tasks by ID in code comments and commits: `R3`, `U2.1`, `D4.2`, `M2.3`. An ID never changes meaning or leaves its doc. Sections may sit in any order, and a merged, moved or removed section's ID becomes an `**Also:**` alias of the section that took its text. Docs cite current IDs. Qualify another repo's IDs, as in `api:D4.2`.
- Main holds the reviewed state of the whole process. Undecided changes are proposals in `docs/proposals/`. A decided change is one design review: the PRD, UX and design in final wording, unbuilt sections marked `**Planned:** M<n>`, plan tasks added, and the proposal deleted. A planned section is a spec to build, not existing code.
- Evidence goes in `docs/analyses/` and is never rewritten: spikes, research, incident and outcome reviews. Unscheduled ideas go under Later in the plan.
- A milestone is done when `docs/user/`, the UX and the design match what was built, its planned markers are gone and its plan file is deleted.
- Docs describe the current state of the process. Git keeps the history. Write plainly and briefly: no em dashes, marketing, time estimates or real names. Split a doc past 600 lines into one file per chapter.
- Text users read, in `docs/user/`, the README or the product, uses short sentences that each say one thing, with no colons, em dashes or lists of three. The README sells the project: a summary line, why it is worth using, the fewest steps to start, and links.

## Workflow

- Develop on `main` and commit directly, unless this file says outside the block that the project is in team mode. Then every change goes through a reviewed pull request, current with main before it merges.
- Each commit is one change with its tests and docs, made after `just check` passes. The subject is a short sentence, under 72 characters, saying what changed and why, citing IDs. A body says why when the subject can't. No `feat:` prefixes. The message ends with a `Change:` trailer, one of added, changed, deprecated, removed, fixed, security, ops, docs or internal, and the first six add a `Changelog:` sentence for users.
- A refactor keeps behavior, moves ID citations with their code and updates the D sections it changes. One that changes the design starts as a proposal.
- New behavior comes with tests through public interfaces. A bug fix starts with a failing test. `just test` needs no network, credentials or real user data.
- Prefer existing dependencies. A new one that shapes the design is recorded in the design. Commit lock files.
- Never commit secrets. Local settings go in a gitignored `.env`, documented by a committed `.env.example`.
- Releases are annotated `v<semver>` tags listing user-visible changes.

## Tooling

- `just` lists the recipes. The root has `build`, `test`, `lint` and `check`, plus `fmt`, `run`, `setup` and `install` where they apply. `install` installs from the checkout and updates when run again.
- Each component has its own justfile, exposed with `mod`. A build never runs tests. Every justfile starts with `_default:` running `@just --justfile {{source_file()}} --list`.
- Apps keep data and config in the OS's per-user directories, never a new folder in the home directory. Paths never contain spaces, so on macOS prefer XDG over `~/Library/Application Support`.
<!-- devkit:end -->
