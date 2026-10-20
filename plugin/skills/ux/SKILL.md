---
name: ux
description: In a project that uses devkit, write or update the UX doc, docs/ux.md, covering flows, screens, interaction rules and the design system. Use when the user asks for UX, flows, wireframes, screens or interaction design, or when a change adds or alters an interface.
---

# UX doc

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 1 and 3.6. The template is `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/ux.md`. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

`docs/ux.md` says how people experience the product. The PRD says what and why, and the design how it is built. A product with no interface beyond commands may not need one, since its user docs cover the surface.

## Writing

1. Read `docs/prd.md`, the existing interface, and research analyses. Ask who the users are if the PRD doesn't say.
2. Fill the template, cutting sections with nothing real to say. Number sections so code can cite them, as in `// Empty state, U4.2`.
3. Draw each flow as a Mermaid diagram with a caption, and cover errors and empty states.
4. Put screens in `docs/ux/` as PNG or SVG. Describe in words what each shows, so an agent can work from the text alone. Link the design tool's source when there is one.
5. Cite the R numbers each part serves.
6. Add it to `docs/README.md`.

## Updating

- A decided change is written through `devkit:design-review`, with new sections marked planned. Outside a design review, edit only to match what was built.
- Read `git log --grep` for a section's ID before changing it.
- Never renumber. New sections take the next free number at their level, and may sit where they read best. To merge, split, move or remove sections, use `devkit:restructure`.
- Search the code for citations of changed sections and fix or flag them.
