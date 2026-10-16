---
name: proposal
description: In a project that uses devkit, write a proposal for an undecided change, such as a feature, rewrite, library switch or spike. Use when the user asks for a proposal, RFC or spike plan, or wants to explore a change before committing to it.
---

# Proposal

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first. The template is `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/proposal.md`. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

A proposal is an argument for one change: the problem, the options and the case for one. It is deleted once decided, so write it to be decided on. The final wording of the docs is written at design review, not here. A change that needs no argument skips the proposal and goes to `devkit:design-review`.

1. If `docs/proposals/` already has one for this change, update it instead.
2. Read the PRD, the UX and design sections the change touches, related analyses, open proposals, `git log --grep` for the cited IDs, and the code.
3. Write `docs/proposals/<slug>.md` from the template, with Status draft. Ask which docs the change touches: requirements, UX, design or several. Name the R, U and D sections it adds or alters, and what each would say.
4. Under Dependencies, link each proposal, plan task or outside condition that must hold first, and say whether it does yet.
5. For a spike, list the questions it answers, each with a pass bar set before it runs.
6. Put each rejected option under Alternatives considered with its concrete trade-off.
7. Add it to `docs/README.md`.

When updating, edit it to say what is proposed now and update Status, with no revision history. When feedback comes from outside git, the commit body says what was raised. When the user decides, use `devkit:design-review`.
