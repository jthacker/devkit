---
name: design
description: In a project that uses devkit, write or update the design doc, covering how the system works and why. Use when the user asks for a design doc, architecture or technical spec, or to update the design after a decision.
---

# Design doc

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first. The template is `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/design.md`. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

## Writing

1. Read `docs/prd.md` and `docs/ux.md` if there is one, and raise their open questions that would change the design first.
2. Read the existing code and analyses.
3. Most of the length goes to the chosen solution: architecture, data model, key flows, interfaces, and the rules the code must follow. Each section gives the rule, the reasoning, and any measurement behind it.
4. Cite the R and U numbers each part serves. A requirement served nowhere becomes an open question. Where a threat model matters, give it a Security section.
5. Options not chosen go in Alternatives considered, each with the concrete trade-off that ruled it out.
6. Where choosing needs research, suggest a spike with `devkit:proposal` rather than guessing.

When the design is first written and reviewed, suggest `devkit:plan`.

## Updating

- A decided change that isn't built goes through `devkit:design-review`, as planned sections. Otherwise edit the section the change belongs in, so it describes the system as built. A decision lives in the section it governs, with its reasoning.
- Read `git log --grep` for a section's ID and its aliases before changing it.
- Never renumber. New sections take the next free number at their level, and may sit where they read best. To merge, split, move or remove sections, use `devkit:restructure`.
- An option the change rules out moves to Alternatives considered.
- Search the code for citations of changed sections, such as `D4.2`, and fix or flag them.
- Past 600 lines, propose splitting by chapter as section 5 describes.
