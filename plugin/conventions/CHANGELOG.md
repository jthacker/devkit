# Conventions changelog

Each version of the conventions gets a section, newest first. The heading is `## v<N>: <one-line summary>`, which the session hook shows to projects that are behind. The section says what changed and gives the migration: the steps an agent follows to bring a project from version N-1 to N. `devkit:upgrade` applies them in order.

A migration must be safe to run on a project with work in progress. It moves and rewrites docs rather than deleting content, and says so when a step needs the user's judgment.

## v4: Rules for building sentences and paragraphs

The conventions said what to leave out of a sentence but not how to build one, so docs passed the linter and still buried their point. New section 4.2 says how to build sentences and paragraphs in every doc. Each sentence carries one idea, with the actor as its subject. Each thing has one name. Each paragraph opens with its point. The rules draw on Google's technical writing courses and Williams's *Style*. They set no word counts, and no linter checks them.

The managed block gains one sentence carrying the three core rules. `devkit:audit` reads paragraphs changed since the last upgrade against them.

### Migration from v3

1. Nothing to move. Existing docs follow the rules as they are written or edited.
2. Offer to audit the docs against section 4.2 with `devkit:audit`. Fix only what the user approves.

## v3: Stricter checks on links and planned sections, and an ideas file

`lint-docs.sh` now fails on a link to an anchor that its Markdown file doesn't define, such as `[Retries](#42-retries)` after fmt renumbered that heading. An anchor is an HTML `id` or `name`, or the slug GitHub gives a heading. Before, it checked only that the file existed, so links to old heading slugs passed `just check` after the v2 upgrade.

Planned work is harder to mistake for built work (section 3.6). Every heading and requirement inside a planned section carries its own marker, and the linter fails on one that doesn't, since a reader who follows a link to a subsection never sees its parent's marker. `fmt-docs.sh` adds "(planned)" to links and contents entries that point at a planned section, so a link from built text doesn't read as built. Overviews, diagrams and tables show only what is built, and a planned change to one goes in a planned subsection.

Unscheduled ideas and follow-ups now go in `docs/ideas.md`, one line each, not under the plan's Later (section 3.2). A growing list of ideas buried the scheduled work, and the plan should hold only what helps decide what to do next.

The plan template names `plan/` as a path instead of linking it. The folder is gone once the last milestone file is deleted, so the link failed the lint.

The PRD template's section on the core idea is now `## Approach`, not `## What we're building`. The old heading read as a casual aside, and Approach says how the product meets the problem without reading as the design.

Open questions in the PRD, `ux.md`, design and proposals are numbered, as in `- **Q2. Retries.** ...`, so people can name one in discussion (section 19). The numbers are local to the doc and may change as questions are settled.

When a decision is the user's, agents take each question on its own (section 20). They research it, give the options with pros and cons, and recommend one when one is better. The managed block carries the rule, and the new `devkit:decide` skill walks a doc's open questions this way. Before, only a design review gave research and a recommendation.

### Migration from v2

1. Replace `.devkit/lint-docs.sh` and `.devkit/fmt-docs.sh` with the current ones, executable.
2. Run `just lint`. For each broken link it reports, find the section the old anchor named, usually by its title in the slug, and link it by ID, as in `[Retries](#design-7kq3)`, or by a heading that exists. Ask the user about any link whose target is unclear.
3. For each heading or requirement it reports inside a planned section without a marker, add the marker, usually naming its parent's milestone. If one is already built, ask the user, since the parent's marker may be wrong.
4. Run `just fmt`. It titles the fixed links and adds "(planned)" to links to planned sections.
5. Read the overviews, diagrams and tables in the PRD, `ux.md` and design for planned work shown as built. With the user's agreement, move each into a planned subsection of its section.
6. If `docs/prd.md` has a `What we're building` heading, offer to rename it to `Approach`, keeping its number and ID anchor. Run `just fmt` so links titled with the old heading take the new one. The user may keep the old heading.
7. If `docs/plan.md` has a Later section with items, move them to `docs/ideas.md` under a `# <Name>: Ideas` heading, from the template, one line each. Keep their wording and links, adjusting relative links for the new file. Remove the Later section from the plan.
8. Move ideas kept anywhere else in the plan, such as in Risks or a milestone's notes, only if the user agrees.
9. Add `docs/ideas.md` to `docs/README.md`, and point links to the plan's Later at it.
10. If `docs/plan.md` links `[plan/](plan/)`, write it as `` `plan/` `` instead.
11. Number the open questions in `docs/prd.md`, `docs/ux.md`, `docs/design.md` and each proposal from Q1, in their current order, as list items that start `**Q<n>. <Short title>.**`. Keep each question's wording, and give a short title to one that has none. A numbered list in the PRD becomes a bulleted one, since `just fmt` treats a numbered item with a bold lead there as a requirement.

## v2: Section IDs that never change, with generated numbers

Each section of the PRD, `ux.md` and design gets an ID that names its doc and never changes, such as `design-7kq3`, in an anchor at the end of its heading (section 2). The new `.devkit/fmt-docs.sh`, run by `just fmt`, numbers the sections in reading order, gives new ones IDs and turns citations in docs into links titled with their target. Code cites bare IDs, and commits cite them in a `Refs:` trailer, so docs can be reordered, merged and split without breaking either (section 18). Each doc is one file again, and past 600 lines the linter warns instead of failing (section 5). `lint-docs.sh` runs `fmt-docs.sh --check` and checks citations in code too. The new `devkit:restructure` skill does the moves.

### Migration from v1

1. Check `git status`, and ask before touching docs with uncommitted changes. In a shallow clone, fetch the full history with `git fetch --unshallow`.
2. Replace `.devkit/lint-docs.sh` and the managed block, and copy `fmt-docs.sh` into `.devkit/`, executable. Run `.devkit/fmt-docs.sh` from the root `fmt` recipe, adding the recipe if there isn't one.
3. Run `.devkit/fmt-docs.sh --adopt`. It joins each doc split by chapter back into one file, its top file followed by its chapter files in contents order. It gives every heading of the PRD, `ux.md` and design, and every requirement, a new ID, and keeps the old number as a second anchor, as in `<a id="design-7kq3"></a><a id="D4.2"></a>`. It turns the PRD's `**R1.2**` items into numbered requirements and citations in docs into links. Show the user the diff before going on.
4. Fix what `--adopt` couldn't: requirements written another way, such as in a table, and sentences that read oddly once a citation became a link.
5. `--adopt` ends with a list of the lines outside `docs/` that name an old ID. Rewrite each one that cites a section to the new ID, and leave identifiers such as a variable named `R2`. Show the user the rewrite as one diff. This step isn't optional, since once the docs are reordered, heading 4.2 may be a different section.
6. Give test fixtures and vendored code that hold example IDs the `devkit-examples` attribute in `.gitattributes`.
7. Run `just lint` and fix what it reports.
8. Offer the user a GitHub autolink per doc, such as prefix `design-` pointing at `https://github.com/<owner>/<repo>/blob/main/docs/design.md#design-<num>`, so bare IDs in commits, pull requests and issues link to their section. Autolinks need a GitHub plan that has them.

Commits keep their old IDs, and `git log --grep D4.2` still finds them. The section an old ID names is found by grepping for its anchor, `id="D4.2"`.

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
