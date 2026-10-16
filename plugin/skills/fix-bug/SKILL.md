---
name: fix-bug
description: In a project that uses devkit, fix a bug by reproducing it, writing a failing test, fixing the cause and correcting the design if it was wrong. Use when the user reports a bug, crash, regression or wrong behavior.
---

# Fix a bug

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 9 and 11. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so follow its own rules instead.

1. **Read** the user docs and design for the behavior, incident reviews in `docs/analyses/`, and `git log --grep` for the cited IDs. Behavior a planned section describes isn't built yet, so its absence isn't a bug.
2. **Reproduce it.** Find the exact steps, the expected result and the actual one. If it won't reproduce, say what you tried and ask. Don't fix by guessing.
3. **Write a failing test** at the lowest level that shows the bug, through a public interface. Run it and watch it fail.
4. **Find the cause**, not just the symptom. Search for the same mistake elsewhere.
5. **Decide where the fault is.**
   - The code breaks a rule the design states: fix the code.
   - The design is wrong or silent: fix the code and the design section. Ask if the right behavior isn't obvious.
   - The PRD is wrong about what users need: stop and raise it.
   - The fix needs a design change beyond a correction: write a proposal with `devkit:proposal` instead.
6. **Fix it** with the smallest change that removes the cause. Restructuring waits for a separate commit.
7. Run `just check` until it passes.
8. If users can hit it again, such as through bad input or an old config, add a `docs/user/troubleshooting.md` entry.
9. Commit the test and fix together. If the bug caused an incident, suggest an incident review with `devkit:analysis`. The subject says what was wrong, such as `Fix lost edits when two sync retries overlap, D8.3`. End it with `Change: fixed` and a `Changelog:` sentence saying what users no longer hit, or `Change: security` for a vulnerability.
