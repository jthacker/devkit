# devkit: Plan

The work left to do, in order. Tasks cite the sections they build by ID, and `just fmt` links them. Each milestone has its own file in [plan/](plan/), listed here in order. Check tasks off as they land. When a milestone is done, delete its file and its line here.

## Milestones

1. [M2. Trial on a new project](plan/M2.md): use devkit for real on a new project before changing anything that exists.
2. [M3. Adopt in existing projects](plan/M3.md): adopt the conventions in the existing projects the user picks.
3. [M4. Publish](plan/M4.md): install from GitHub for anyone, keeping the checkout route for forks.
4. [M5. Planned sections and design review](plan/M5.md): decided work as planned sections, reviewed once.
5. [M6. Release, teams and repos](plan/M6.md): releases, team mode and products across repos.

## Requirement coverage

| Requirement | Milestones |
| --- | --- |
| [PRD: Start a project in one request](prd.md#prd-gfx8) | M2.1 |
| [PRD: One format](prd.md#prd-830w) | M2.2 |
| [PRD: Conventions evolve in one place](prd.md#prd-by6e) | M2.4 |
| [PRD: Existing projects catch up on request](prd.md#prd-a19r) | M2.4, M3 |
| [PRD: One way of working](prd.md#prd-27en) | M2.5 |
| [PRD: Drift is visible](prd.md#prd-5j7p) | M3.3 |
| [PRD: Anyone can install it](prd.md#prd-25zb) | M4 |
| [PRD: Lightweight change management in the repo](prd.md#prd-8z7e) | M5, M6 |
| [PRD: Any team size](prd.md#prd-77ak) | M6 |
| [PRD: The repo is all an agent needs](prd.md#prd-5h1g) | M5 |
| [PRD: Feedback without git](prd.md#prd-kb8q) | M6 |

## Risks

- **Skill descriptions that trigger too often.** Once installed, devkit's skills are offered in every project, including ones that don't use devkit. The doc skills check for the managed block and ask first, but a skill could still be picked for an unrelated request. Watch for it during M2, and after M4.4.
- **Publishing before the trial.** M4 can land before M2 is done, so other people may find the first rough edges.
- **Migrations that don't fit.** Agent-run migrations depend on clear steps. The v0 adoption is the hardest and is first tried in M3.2.

## Later

- Mirrors for feedback outside git: publish a proposal or design review's docs as a copy to a tool people comment in, and pull the comments back as proposed edits, never syncing edits back ([Design: Syncing with a wiki](design.md#design-pwq5)).
