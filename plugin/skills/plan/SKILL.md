---
name: plan
description: In a project that uses devkit, write or update the implementation plan, with milestones and stable task IDs. Use when the user asks for a plan, milestones, a roadmap, or what to work on next.
---

# Plan

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially section 3.2. The templates are `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/plan.md` and, for each milestone, `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/plan/M1.md`. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

## Writing

1. Read `docs/prd.md`, `docs/ux.md` if there is one, and `docs/design.md`, including the planned sections, which are what the plan builds.
2. Order the work so the riskiest assumptions are tested first and something runs end to end early, usually a thin walking skeleton.
3. Each milestone has its own file, `docs/plan/M<n>.md`, with a goal, a **Done when** line with an observable result, and tasks numbered `M<n>.<m>`. `docs/plan.md` lists the milestones in order with a link and a line each. A milestone's number matches the planned markers that name it.
4. Write each task for an agent to pick up cold: the files or components it touches, the U and D sections it implements, and the test or recipe that checks it. A task fits in one working session. Never name who does it. In a product repo, say which repo each task is in, as in `M7.2 (api)`.
5. Fill the requirement coverage table. Every R number maps to a milestone or is listed as deferred.
6. List decisions that block upcoming work under Decisions needed, with the options. Don't decide them silently.

## Keeping it current

- Tick tasks as they land. New tasks go at the end of their milestone. Never renumber.
- A decision goes into the design section it governs, and leaves Decisions needed.
- A finished milestone goes through `devkit:finish-milestone`.
- Unscheduled ideas go under Later.

Asked what's next, answer with the first unblocked task and what it needs, and offer `devkit:implement`.
