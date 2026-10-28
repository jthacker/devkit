# devkit: Plan

The work left to do, in order. Tasks cite the sections they build by ID, and `just fmt` links them. Each milestone has its own file in `plan/`, listed here in order. Check tasks off as they land. When a milestone is done, delete its file and its line here.

## Milestones

1. [M8. Rules for sentences and paragraphs](plan/M8.md): the conventions say how to build sentences and paragraphs, not only what to leave out.

## Requirement coverage

| Requirement | Milestones |
| --- | --- |

## Risks

- **Skill descriptions that trigger too often.** Once installed, devkit's skills are offered in every project, including ones that don't use devkit. The doc skills check for the managed block and ask first, but a skill could still be picked for an unrelated request. Watch for it in projects without devkit.
- **Migrations that don't fit.** Agent-run migrations depend on clear steps. The v0 adoption is the hardest.
