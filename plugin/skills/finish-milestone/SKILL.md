---
name: finish-milestone
description: In a project that uses devkit, close out a finished milestone, checking that user docs, UX and design match what was built, removing its planned markers and its plan file. Use when the user says a milestone is done or all its tasks are ticked.
---

# Finish a milestone

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 3.4 and 3.6.

1. **Check it's done.** Every task in its file in `docs/plan/` is ticked, the **Done when** result holds, and `just check` passes. In a product repo, every component change the tasks cite has merged. If not, stop and report what's missing.
2. **User docs.** `docs/user/` describes every behavior the milestone added or changed. Run the commands the pages show. Fix mismatches with `devkit:user-docs`.
3. **UX and design.** Compare what was built with the U and D sections the tasks cite. Where they differ, ask whether the code or the doc is right, and update the doc to match, with the reasoning for any decision made along the way.
4. **Planned markers.** Remove every `**Planned:** M<n>` naming this milestone, in the PRD, UX and design. Change nothing else in those sections. Merge a planned subsection into the built text, diagram or table it changes, keeping its ID as an extra anchor (CONVENTIONS section 18). Run `just fmt`, which drops "(planned)" from links to the sections.
5. **Plan.** Delete the milestone's file and its line in `docs/plan.md`. Move unfinished follow-ups to a later milestone or `docs/ideas.md`. Drop requirements no remaining milestone covers from the coverage table.
6. Commit as `Finish M<n>: <name>` with the trailers `Refs: M<n>` and `Change: docs`, and report what changed and what's left for the user to decide.
