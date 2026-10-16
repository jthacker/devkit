---
name: implement
description: In a project that uses devkit, implement a plan task, such as M2.3 or the next one, with tests, docs and a commit citing its IDs. Use when the user asks to implement, build or start a task, feature or milestone.
---

# Implement a task

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 2, 3.6, 9, 11 and 14. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so follow its own rules instead.

1. **Pick the task.** Take the one the user names, or the first unchecked task in the milestone files `docs/plan.md` lists, in order, that nothing blocks. Work with no task that is more than a small change gets one in the plan first, through `devkit:design-review` if it changes what the docs say, or a proposal with `devkit:proposal` if it isn't decided.
2. **Read** the task, the R, U and D sections it cites, the built sections they depend on, and the code it touches. A section marked `**Planned:**` is the spec to build, not a description of existing code. Read `git log --grep` for the cited IDs to learn why they say what they do. If the docs don't say how, or the task conflicts with them, ask rather than deciding silently.
3. **Start green.** Run `just check`. If it fails before any change, report it and stop.
4. **Build** in small steps, with tests through public interfaces. Cite the U or D section in a comment where code follows a rule a reader would otherwise question. In team mode, work on a branch and open a pull request.
5. **Finish green.** Run `just check` until it passes.
6. **Docs.** If users see the change, update `docs/user/` with `devkit:user-docs`. If what was built differs from the planned section, update it, and ask first if it changes direction. Record decisions made along the way in the section they govern. Planned markers stay until the milestone finishes.
7. **Commit.** Tick the task in its milestone file and commit it all together, citing the task, such as `Retry failed syncs so edits survive a dropped connection, M2.3`. End it with the trailers of CONVENTIONS section 17: the `Change:` value for what users see, and a `Changelog:` sentence when they notice it.

When every task in the milestone is ticked, suggest `devkit:finish-milestone`.
