---
name: audit
description: In a project that uses devkit, check it against the current conventions and fix the drift the user approves. Use when the user asks to audit or check a project's conventions, or after an upgrade.
---

# Audit a project

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first. `devkit:upgrade` applies migrations between versions. An audit compares the project with the rules as they are now, to catch drift that no migration covers.

If `AGENTS.md` has no `devkit:begin` block, offer `devkit:upgrade` to adopt devkit instead. If it records an older version, upgrade first.

## 1. Check

1. Run `${CLAUDE_PLUGIN_ROOT}/conventions/templates/lint-docs.sh .`, and diff that file, `fmt-docs.sh` and `check-commits.sh` against their copies in `.devkit/`.
2. Check what the linter can't, section by section:
   - **1, 3:** no docs outside the document set, such as `todo.md` or a decisions file. No changelogs, done lists or decision logs in docs. The plan is in milestone files. No milestone with every task ticked. No proposal the docs already contain. No planned section whose code is already built and shipped. No idle milestone: if no commit in 90 days has touched its plan file or cited its tasks, as `git log -1 --format=%cr` with `-- docs/plan/M<n>.md` and with `--grep 'M<n>\.'` show, ask whether it is still wanted. Reschedule it, or drop its planned sections in a reviewed change (section 3.6), keeping the idea in `docs/ideas.md` if it may come back. Overviews, diagrams and tables show only what is built.
   - **2:** the linter checks that each ID cited in code exists. Read the citations, and check that each section still describes the code that cites it, or is a planned section the code is building. Old IDs such as `D4.2` left in code after the v2 migration are rewritten to the new ID. M citations to finished milestones are fine. Commits since the upgrade cite IDs in `Refs:`, not the subject.
   - **15:** qualified citations such as `api:design-7kq3`, with the related repos `AGENTS.md` lists cloned. Each names a section that exists there.
   - **6:** `CLAUDE.md` is only `@AGENTS.md`. The managed block matches `${CLAUDE_PLUGIN_ROOT}/conventions/templates/agents-block.md` for the recorded version.
   - **7:** each justfile against the recipe rules.
   - **8:** where the app keeps data.
   - **9:** recent commit subjects, and release tags if any. In team mode, that `main` is protected by review.
   - **10:** the README's four parts, and that Why says what changes for users rather than listing features.
   - **11:** `just test` passes offline.
   - **13:** `git ls-files` shows no secrets or `.env`. `.env.example` lists every variable the code reads.
3. Skip sections that don't apply, such as data locations for a library.

## 2. Report and fix

List the findings by section, each with its fix. Mark which fixes are mechanical and which need the user's judgment. A committed secret comes first, with a note that it must be rotated.

Apply the fixes the user approves and commit them as `Fix drift from devkit conventions v<N>`, with the `Change:` value that fits, usually `docs` or `internal`. Add larger ones to the plan as tasks. Never rewrite an analysis or git history.
