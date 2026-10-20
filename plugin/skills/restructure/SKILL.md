---
name: restructure
description: In a project that uses devkit, restructure the PRD, UX doc or design by merging, splitting, moving, reordering or removing sections and chapters, keeping every ID. Use when the user asks to reorganize, reorder, merge or split chapters or sections of these docs.
---

# Restructure a doc

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 2, 5 and 18. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

A restructure changes where text sits, not what it says. If the user also wants a section to say something different, do that as a separate change, through `devkit:design-review` when it isn't built.

## 1. Map

1. Read the doc and its contents, and `git status`. Ask before touching docs with uncommitted changes.
2. Write a table of every section that changes: its old ID, what happens to it, and its new ID. Use the moves in section 18. A new section or chapter takes the next free number at its level, including numbers held by aliases.
3. For each split, say which part keeps the original ID. Run `git grep -nE '[^A-Za-z0-9_]<ID>([^0-9.]|$)'` for each split ID, and list the citations in code and docs whose meaning moved to a new part.
4. Show the user the table and the citations to change, and wait for approval.

## 2. Apply

1. Move the text without rewording it, except for sentences that point at other sections by position, such as "the chapter above".
2. Add `**Also:**` lines under the sections that took over IDs, after any planned marker. Keep existing aliases with the text they belong to.
3. Rebuild the contents in reading order. In a split doc, rename chapter files to match their numbers, as in `docs/design/9-retries.md`, and fix links to them.
4. Update citations in docs to current IDs, and in code where a split moved the meaning. Leave analyses alone, since they are never rewritten.
5. Run `just check`. The linter fails on a doc citing an alias and on an ID that is gone.
6. Commit with `Change: docs` and a body mapping each old ID to its new one, such as `D6.1, D6.3 merged into D4.2`, so `git log --grep` finds the move under either ID.
