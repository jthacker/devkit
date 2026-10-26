---
name: design
description: In a project that uses devkit, write or update the design doc, covering how the system works and why. Use when the user asks for a design doc, architecture or technical spec, or to update the design after a decision.
---

# Design doc

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first. The template is `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/design.md`. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

Before changing any file, compare the `conventions=N` marker in `AGENTS.md` with `${CLAUDE_PLUGIN_ROOT}/conventions/VERSION`. If the project is behind, stop, name both versions and offer `devkit:upgrade`. If the plugin is behind, stop and say to update the plugin.

## Writing

1. Read `docs/prd.md` and `docs/ux.md` if there is one, and raise their open questions that would change the design first, offering `devkit:decide` to settle them.
2. Read the existing code and analyses.
3. Most of the length goes to the chosen solution: architecture, data model, key flows, interfaces, and the rules the code must follow. Each section gives the rule, the reasoning, and any measurement behind it.
4. Cite the requirements and UX sections each part serves by ID. Write new sections as plain headings, and run `just fmt` to number them, give them IDs and link the citations. A requirement served nowhere becomes an open question. Where a threat model matters, give it a Security section.
5. Options not chosen go in Alternatives considered, each with the concrete trade-off that ruled it out.
6. Where choosing needs research, suggest a spike with `devkit:proposal` rather than guessing.

When the design is first written and reviewed, suggest `devkit:plan`.

## Updating

- A decided change that isn't built goes through `devkit:design-review`, as planned sections. Otherwise edit the section the change belongs in, so it describes the system as built. A decision lives in the section it governs, with its reasoning.
- Read `git log --grep` for a section's IDs, its main ID and any extra anchors, before changing it.
- Never edit a number or an ID. New sections are plain headings that may sit where they read best, and `just fmt` does the rest. To merge, split, move or remove sections, use `devkit:restructure`.
- An option the change rules out moves to Alternatives considered.
- Search the code for citations of changed sections, such as `git grep design-7kq3`, and fix or flag them.
- Past 600 lines, look for content that belongs elsewhere, as section 5 describes, and propose moving it.
