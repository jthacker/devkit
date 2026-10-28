<!-- devkit:begin conventions={{VERSION}} -->
## Docs

This project follows the devkit conventions, version {{VERSION}}. Only devkit's upgrade edits this block and `.devkit/`.

- `docs/README.md` indexes the docs: `prd.md` says what to build and why, `ux.md` how people experience it, `design.md` how it works, `plan.md` and `plan/` what is left. Read the design before changing behavior, and `git log --grep` a section's IDs for why it is that way.
- Each section of the PRD, `ux.md` and design has an ID that never changes, such as `prd-4hz8`, `ux-c3pa` or `design-7kq3`, in an anchor at the end of its heading. Read one with `grep -n 'id="design-7kq3"'` and on to the next heading. Plan tasks are `M2.3`. Code comments and analyses cite bare IDs, and commits cite them in a `Refs:` trailer. Other docs link sections by title, as in `[PRD: Sync](prd.md#prd-m2c7)`. Qualify another repo's IDs, as in `api:design-7kq3`.
- Write a new section as a plain heading and a citation in a doc as a bare ID, then run `just fmt`. It numbers sections, gives new ones IDs and turns bare IDs into links. Never edit a number or an ID. A merged section keeps the absorbed ID as an extra anchor, a section moved to another doc keeps its old ID the same way, and a deleted one leaves nothing. An old ID such as `D4.2` is an extra anchor, never a heading number.
- Main holds the reviewed state of the whole process. Undecided changes are proposals in `docs/proposals/`. A decided change is one design review: the PRD, UX and design in final wording, unbuilt sections marked `**Planned:** M<n>`, plan tasks added, and the proposal deleted. A planned section is a spec to build, not existing code.
- Evidence goes in `docs/analyses/` and is never rewritten: spikes, research, incident and outcome reviews. Unscheduled ideas go in `docs/ideas.md`, not the plan.
- A milestone is done when `docs/user/`, the UX and the design match what was built, its planned markers are gone and its plan file is deleted.
- Docs describe the current state of the process. Git keeps the history. Write plainly and briefly: no em dashes, marketing, time estimates or real names. Open each paragraph with its point, give each sentence one idea and call each thing by one name. Each doc is one file. Past 600 lines, move what belongs elsewhere.
- Text users read, in `docs/user/`, the README or the product, uses short sentences that each say one thing, with no colons, em dashes or lists of three. The README sells the project: a summary line, why it is worth using, the fewest steps to start, and links.

## Workflow

- Develop on `main` and commit directly, unless this file says outside the block that the project is in team mode. Then every change goes through a reviewed pull request, current with main before it merges.
- Each commit is one change with its tests and docs, made after `just check` passes. The subject is a short sentence, under 72 characters, saying what changed and why. A body says why when the subject can't. No `feat:` prefixes. The message ends with a `Refs:` trailer listing the IDs it touches, if any, and a `Change:` trailer, one of added, changed, deprecated, removed, fixed, security, ops, docs or internal, and the first six add a `Changelog:` sentence for users.
- A refactor keeps behavior, moves ID citations with their code and updates the design sections it changes. One that changes the design starts as a proposal.
- New behavior comes with tests through public interfaces. A bug fix starts with a failing test. `just test` needs no network, credentials or real user data.
- Prefer existing dependencies. A new one that shapes the design is recorded in the design. Commit lock files.
- Never commit secrets. Local settings go in a gitignored `.env`, documented by a committed `.env.example`.
- Releases are annotated `v<semver>` tags listing user-visible changes.
- When a decision is the user's, take each question on its own. Research it in the repo, and on the web when it turns on outside facts. Give the options with pros and cons, and recommend one when one is better. Never settle one silently.

## Tooling

- `just` lists the recipes. The root has `build`, `test`, `lint` and `check`, plus `fmt`, `run`, `setup` and `install` where they apply. `install` installs from the checkout and updates when run again.
- Each component has its own justfile, exposed with `mod`. A build never runs tests. Every justfile starts with `_default:` running `@just --justfile {{source_file()}} --list`.
- Apps keep data and config in the OS's per-user directories, never a new folder in the home directory. Paths never contain spaces, so on macOS prefer XDG over `~/Library/Application Support`.
<!-- devkit:end -->
