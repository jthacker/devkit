---
name: prd
description: In a project that uses devkit, write, update or critique the product requirements doc (PRD). Use when the user asks for a PRD or requirements, or to flesh out or review what a project should do and for whom.
---

# PRD

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first. The template is `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/prd.md`. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

Before changing any file, compare the `conventions=N` marker in `AGENTS.md` with `${CLAUDE_PLUGIN_ROOT}/conventions/VERSION`. If the project is behind, stop, name both versions and offer `devkit:upgrade`. If the plugin is behind, stop and say to update the plugin.

The PRD says what and why: the problem, the users, what good looks like, the requirements and the non-goals. How belongs in the design and plan. Don't implement anything.

## Writing

1. Start from what the user gave, any idea doc, and the existing code and docs.
2. If what it is, who it's for or what problem it solves is unclear, ask before writing.
3. Fill the template. Cut sections with nothing real to say.
4. Group requirements under a heading per area, each a numbered item with a bold title, as the template shows. Each is testable and says what, not how. Run `just fmt` to number them and give each an ID.
5. Make success criteria checkable, and say how each is measured, so an outcome review can check it after a release. "Users find it easy" isn't checkable. "A new user installs it and joins a game in two clicks" is.
6. Search for prior art when it would sharpen the problem or scope, and cite it under References.

## Updating or critiquing

1. Read the PRD's recent `git log` and diffs.
2. Look for gaps: requirements without success criteria and the reverse, users no requirement serves, scope that contradicts the non-goals, and how-level detail.
3. Say which design and plan sections a change affects.
4. Never edit a requirement's ID. New ones are numbered items in their area, and `just fmt` gives them IDs. To merge, split or move requirements, use `devkit:restructure`. A decided requirement that isn't built goes through `devkit:design-review`, marked planned.

End by naming, by number, the open questions that most need the user's answer, and offer to settle them with `devkit:decide`.
