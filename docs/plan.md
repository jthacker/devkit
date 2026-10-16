# devkit: Plan

The work left to do, in order. Design references such as D7.3 point into [design.md](design.md), and requirement references such as R5 into [prd.md](prd.md). Each milestone has its own file in [plan/](plan/), listed here in order. Check tasks off as they land. When a milestone is done, delete its file and its line here.

## Milestones

1. [M2. Trial on a new project](plan/M2.md): use devkit for real on a new project before changing anything that exists.
2. [M3. Adopt in existing projects](plan/M3.md): adopt the conventions in the existing projects the user picks.
3. [M4. Publish](plan/M4.md): install from GitHub for anyone, keeping the checkout route for forks.
4. [M5. Planned sections and design review](plan/M5.md): decided work as planned sections, reviewed once.
5. [M6. Release, teams and repos](plan/M6.md): releases, team mode and products across repos.

## Requirement coverage

| Requirement | Milestones |
| --- | --- |
| R1 | M2.1 |
| R2 | M2.2 |
| R4 | M2.4 |
| R5 | M2.4, M3 |
| R7 | M2.5 |
| R8 | M3.3 |
| R9 | M4 |
| R10 | M5, M6 |
| R11 | M6 |
| R12 | M5 |
| R13 | M6 |

## Risks

- **Skill descriptions that trigger too often.** Once installed, devkit's skills are offered in every project, including ones that don't use devkit. The doc skills check for the managed block and ask first, but a skill could still be picked for an unrelated request. Watch for it during M2, and after M4.4.
- **Publishing before the trial.** M4 can land before M2 is done, so other people may find the first rough edges.
- **Migrations that don't fit.** Agent-run migrations depend on clear steps. The v0 adoption is the hardest and is first tried in M3.2.

## Later

- Check code citations in the doc linter, if a pattern proves reliable enough across stacks.
- Mirrors for feedback outside git: publish a proposal or design review's docs as a copy to a tool people comment in, and pull the comments back as proposed edits, never syncing edits back (D10.14).
