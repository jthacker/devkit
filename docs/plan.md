# devkit: Plan

The work left to do, in order. Tasks cite the sections they build by ID, and `just fmt` links them. Each milestone has its own file in [plan/](plan/), listed here in order. Check tasks off as they land. When a milestone is done, delete its file and its line here.

## Milestones

1. [M5. Planned sections and design review](plan/M5.md): decided work as planned sections, reviewed once.
2. [M6. Release, teams and repos](plan/M6.md): releases, team mode and products across repos.

## Requirement coverage

| Requirement | Milestones |
| --- | --- |
| [PRD: Lightweight change management in the repo](prd.md#prd-8z7e) | M5, M6 |
| [PRD: Any team size](prd.md#prd-77ak) | M6 |
| [PRD: The repo is all an agent needs](prd.md#prd-5h1g) | M5 |
| [PRD: Feedback without git](prd.md#prd-kb8q) | M6 |

## Risks

- **Skill descriptions that trigger too often.** Once installed, devkit's skills are offered in every project, including ones that don't use devkit. The doc skills check for the managed block and ask first, but a skill could still be picked for an unrelated request. Watch for it in projects without devkit.
- **Migrations that don't fit.** Agent-run migrations depend on clear steps. The v0 adoption is the hardest.
