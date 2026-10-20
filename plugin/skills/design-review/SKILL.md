---
name: design-review
description: In a project that uses devkit, write a decided change into the PRD, UX and design as planned sections with plan tasks, ready to review as one change, or reject a proposal. Use when the user accepts, approves or rejects a proposal, or wants a change designed and reviewed without one.
---

# Design review

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 3.5, 3.6 and 14. Act only once the user has said the change is decided, or that a proposal is rejected. `AGENTS.md` says outside the managed block whether the project is in team mode.

## Accepted, or no proposal needed

The result is one change a reviewer reads as a diff of the docs as they will be.

1. **Read** the proposal if there is one, the PRD, `docs/ux.md` and the design sections it touches, open proposals, related analyses, and `git log --grep` for each cited ID.
2. **Cover each role.** Ask what the change means for each doc it touches: what people see in `ux.md`, what it changes in the requirements, and how it works in the design. On a solo project, ask the user one question per role the change touches when the proposal doesn't answer it.
3. **Write the final wording** into the PRD, `docs/ux.md` and `docs/design.md`, as they will read once built. New sections take the next free number at their level, placed where they read best. Mark each new section or requirement `**Planned:** M<n>` with the milestone that builds it. A change to a built section is a planned subsection, and the built text stays. Use `devkit:ux` to start `docs/ux.md` if the change adds the first interface beyond commands.
4. **Move rejected options** to Alternatives considered in the doc they belong to.
5. **Plan the work** with `devkit:plan`: a milestone file per milestone, tasks citing the planned IDs. For a spike, the work is running it and writing the analysis with `devkit:analysis`. Dependencies not yet met become earlier tasks, or entries in Decisions needed if another proposal is still open.
6. **Open questions** go to the design's or UX's Open questions or the plan's Decisions needed. Drop the settled ones.
7. **Delete the proposal** and its row in `docs/README.md`.
8. Run `just check`. Solo, show the user the diff and commit on approval. In team mode, commit on a branch and open a pull request. Either way the subject is `Design <title>`, or `Accept proposal: <title>` when there was one, with the trailer `Change: docs`.

After a rebase in team mode, re-read what is new on main in the sections the change touches. If another design review changed them, rework this one against it before merging.

## Rejected

1. If a reader would wonder why the project doesn't do this, add the option and the reason to the design's Alternatives considered.
2. Delete the proposal and its row in `docs/README.md`. Commit as `Reject proposal: <title>`, with the reason in the body and the trailer `Change: docs`.

## Either way

Update any other proposal whose Dependencies name this one, and tell the user if a rejection leaves one unable to go ahead. When the change resolves feedback from people outside git, the commit body says what was raised and how it was resolved.
