# Conventions changelog

Each version of the conventions gets a section, newest first. The heading is `## v<N>: <one-line summary>`, which the session hook shows to projects that are behind. The section says what changed and gives the migration: the steps an agent follows to bring a project from version N-1 to N. `devkit:upgrade` applies them in order.

A migration must be safe to run on a project with work in progress. It moves and rewrites docs rather than deleting content, and says so when a step needs the user's judgment.

## v2: Restructure docs, keeping IDs as aliases

Sections in the PRD, `ux.md` and design may sit in any order, since an ID is a label, not a position. A restructure merges, splits, moves or removes sections and keeps every ID: the section that takes over an ID's text lists it on an `**Also:**` line (section 18). Docs cite current IDs, while code and commits may keep citing aliases. `lint-docs.sh` reads aliases, fails on a doc citing one, and fails when an ID defined at the base commit is gone. The new `devkit:restructure` skill does the work.

### Migration from v1

1. Replace `.devkit/lint-docs.sh` and the managed block.
2. Run `just lint`. A project that followed v1 passes unchanged.
3. If a section was removed or merged under v1 and code still cites its number, list those citations and ask the user which section each now belongs to. Add the old ID to that section's `**Also:**` line. Skip this if the user doesn't want to look.
4. If CI runs on pull requests, offer to pass the target branch as the base, as in `.devkit/lint-docs.sh . origin/main`, with the full history fetched.

## v1: First version of the conventions

The document set with stable R, U, D and M references, proposals as arguments decided by one design review, planned sections, a plan with one file per milestone, kept analyses, the AGENTS.md managed block, and shared rules for justfiles, app data locations, git, typed commits, the README, tests, dependencies, secrets, agent context, products across repos and refactors. `.devkit/lint-docs.sh` and `.devkit/check-commits.sh` check docs and commits from `just lint`.

### Migration from v0

v0 is a project that doesn't use devkit yet. Adopting the conventions is a bigger change than a normal migration, so propose the whole mapping to the user and wait for approval before changing anything.

1. Make an inventory of the existing docs and agent files: where they are, what each covers, and how big it is.
2. Map each one to the document set in CONVENTIONS.md section 1. Typical mappings:
   - `doc/` becomes `docs/`.
   - `implementation-plan.md`, `proposals/plan.md`, `todo.md` and `ideas.md` merge into the plan. Backlog items go under Later.
   - Spike or experiment results, research and incident reviews go to `docs/analyses/`, using the template's Kind line. Don't rewrite them.
   - Proposals that are already implemented: fold them into the PRD and design, then delete them. Proposals still open stay in `docs/proposals/`, and are decided through `devkit:design-review`.
   - Decision tables and "decisions" sections: each decision still in force goes into the design section it governs, with its reasoning. Rejected options go to the design's Alternatives considered. Then the table is removed.
   - Flows, screens and interaction rules in the PRD or design: offer to move them into `docs/ux.md` as U sections. Skipping this is fine.
   - Finished milestones, done lists and changelogs inside docs are removed. Git keeps them.
3. Write the plan as section 3.2 describes: `docs/plan.md` lists the milestones in order, each linking to `docs/plan/M<n>.md` with its goal, Done when and tasks. Keep existing task IDs.
4. Find what the PRD and design describe but isn't built: sections cited by unchecked tasks, and any the user names. Mark each one the user approves `**Planned:** M<n>` (section 3.6).
5. List what the project does differently from the conventions on purpose, such as a rule in its agent files that conflicts. Ask the user whether each one stays as a project rule outside the managed block or gives way.
6. Ask whether the project is solo or a team. For a team, add a line to `AGENTS.md` outside the block saying the project is in team mode, and offer a `CODEOWNERS` file mapping doc paths to roles. Don't delete or merge existing branches; list them for the user.
7. Ask whether the project is part of a product spread across repos. If so, add a `## Related repos` section to `AGENTS.md` outside the block, with each repo's short name, role and clone URL (section 15).
8. Don't renumber existing design sections, since code and commits may cite them. Add R, D or M IDs only where the doc has no numbering yet. Moved sections leave their numbers unused.
9. Split any doc past about 600 lines into one file per chapter (section 5), after the user approves.
10. If `CLAUDE.md` duplicates `AGENTS.md`, keep the newer or longer content in `AGENTS.md` and replace `CLAUDE.md` with `@AGENTS.md`.
11. Check each justfile against section 7. List what's missing and ask before changing recipes, since CI or scripts may call them.
    - If the default recipe isn't a private `_default` first in the file, rename it. If a script or doc runs `just default`, change it to `just`.
    - Propose `fmt`, `run`, `setup` and `install` recipes where they apply, built from commands the README, docs or CI already use.
12. Copy `lint-docs.sh` and `check-commits.sh` into `.devkit/`, executable, and run them from the root `lint` recipe. If CI runs on pull requests, offer a step that runs `.devkit/check-commits.sh origin/main..HEAD` with the full history fetched. Don't rewrite history; the check skips commits made before it was added.
13. Add `.env`, `.env.*` and `!.env.example` to `.gitignore`. Check `git ls-files` for committed secrets. If there are any, tell the user they must be rotated, and don't rewrite history without asking.
14. If the project builds an app or tool that stores data, config or state, check where it does against section 8. If it uses a new folder in the home directory or a path with a space, don't move it: existing users have data there. Add a plan task to move it with a migration of the user's data.
15. Draft a README as section 10 describes, moving other content to `docs/user/` or `AGENTS.md` rather than deleting it. Show the user the draft, including its Why, and wait for approval.
16. If the project tags releases differently from section 9, ask whether to switch for future releases. Don't retag old ones.
17. Search the docs and examples for real people's names, such as the git user's name. List them and ask before replacing each one with a placeholder.
18. Add the managed block to `AGENTS.md`.
19. Fix links broken by moves, in docs and code, and run `just lint`.
