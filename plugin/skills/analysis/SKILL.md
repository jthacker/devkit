---
name: analysis
description: In a project that uses devkit, write up evidence as an analysis, from a spike, benchmark, user research, an incident review or an outcome review. Use when a spike finishes, after an incident or release, or when the user asks to record what an experiment or study showed.
---

# Analysis

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first. The template is `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/analysis.md`. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

An analysis is evidence. Once written, it is never rewritten to fit later decisions, and `just fmt` leaves it alone. Set its Kind, and cite sections by bare ID, such as `design-7kq3`, never by link, since a link names a doc the section may later leave.

1. Find what it is judged against. A spike or benchmark has pass bars in the plan, the design, or the proposal in git history. Research has the questions it set out to answer. An incident has the expected behavior in the user docs and design. An outcome review has the PRD's success criteria and how each is measured.
2. Write `docs/analyses/<slug>.md` from the template. Report results against the pass bars as they were set. If a bar turns out to be wrong, say so in Findings.
3. Look at the output as well as the numbers, and record defects found by looking.
4. Put screenshots and data in `docs/analyses/<slug>/`. Make Reproducing complete enough to run it again.
5. Add it to `docs/README.md`.
6. Apply the recommendation only as far as the user agrees. Recommendations that change what the docs say go through `devkit:proposal` or `devkit:design-review`, and unscheduled ones go in `docs/ideas.md`.
