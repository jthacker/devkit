---
name: restructure
description: In a project that uses devkit, restructure the PRD, UX doc or design by merging, splitting, moving, reordering or removing sections and chapters, keeping every ID. Use when the user asks to reorganize, reorder, merge or split chapters or sections of these docs.
---

# Restructure a doc

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 2 and 18. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

A restructure changes where text sits, not what it says. If the user also wants a section to say something different, do that as a separate change, through `devkit:design-review` when it isn't built.

## 1. Map

1. Read the doc and `git status`. Ask before touching docs with uncommitted changes.
2. List each section that merges, splits, moves to another doc or is deleted, by ID, with what happens to it. A reorder or a promotion needs no list, since IDs move with their sections.
3. For a merge, say which ID survives, usually the one cited most. For a split, say which part keeps the original ID, and list the citations whose meaning moves to the new part, from `git grep <ID>`.
4. For a delete, list every link and citation of its ID with `git grep`, and say where each one should point or whether it goes.
5. Show the user the list and wait for approval.

## 2. Apply

1. Move the text without rewording it, except for sentences that point at other sections by position, such as "the chapter above".
2. On a merge, keep the absorbed section's anchor after the surviving one on the merged heading. On a move to another doc, keep the heading's anchor, and `fmt` gives it the new doc's ID. On a delete, remove the anchor with the text.
3. Fix by hand the citations whose meaning moved in a split, and those of a deleted section.
4. Run `just fmt`. It renumbers the headings and contents, gives new parts IDs, and points links and code citations at the surviving IDs.
5. Run `just check`. The linter names any link or citation that points nowhere.
6. Commit with a `Refs:` trailer naming every ID involved and `Change: docs`, and a body saying what merged, moved and was deleted, such as `Merged design-b6tn into design-7kq3`.
