# How work flows

devkit keeps every stage of product work in the repo. Main shows what is built and what is planned. Git history shows how it got there.

## Have an idea

Ask Claude to add it to the plan. It waits under Later until you schedule it.

## Argue for a change

Ask for a proposal when a change needs a decision. Claude writes it in `docs/proposals/`. Skip this step when the change needs no argument.

## Decide

Say you accept the proposal, or describe a change you have already decided. Claude writes the change into the docs as they will read once it is built. Sections that aren't built yet are marked as planned. Claude also adds the work to the plan. You review all of it as one diff.

## Design the experience

Ask for UX docs when the product has screens. They live in `docs/ux.md`, with screen images in `docs/ux/`.

## Build

Ask Claude to implement the next task. It treats planned sections as the spec to build.

## Ship

When a milestone's tasks are done, ask Claude to finish it. Claude checks the docs against what was built and removes the planned markers. Ask for a release to tag a version.

Every commit ends with a line naming its kind of change. Changes users notice also get a sentence written for them. A release builds its notes from those sentences.

## Learn

After a release, ask for an outcome review. It checks the PRD's success criteria. What it finds becomes new ideas or proposals.

## Work as a team

Say in `AGENTS.md`, outside the devkit block, that the project is in team mode. Every change then goes through a pull request. A design review is one pull request.

People who don't use git can comment on a pull request in the browser. You can also paste their feedback into a session. Claude records what was decided in the commit.
