---
name: evolve
description: Change the devkit conventions, templates or skills, with a version bump and migration so existing projects can follow. Use when the user wants to change how all projects work, such as "from now on", "change the convention" or "update devkit".
---

# Evolve the conventions

This skill lives in devkit's repo, so it runs in a session in a devkit checkout or a fork (design-79rj). Changes made here reach new projects at once, and existing projects through `devkit:upgrade`. Read `AGENTS.md` first.

## 1. Decide what kind of change it is

- A **convention change** alters what a project should contain: a doc, a folder, a rule, the managed block or `lint-docs.sh`. It needs a version bump and a migration.
- A **skill change** alters how a skill works, not what a project should contain. It needs no bump.

Rules stay independent of language, library and domain. Separate what is general from what belongs to one project. Project-only rules go in that project's `AGENTS.md`, outside the managed block.

A new skill must produce, update or depend on a lifecycle doc (design-0qqy). Anything else doesn't ship in the plugin.

## 2. Make the change

1. Edit `plugin/conventions/CONVENTIONS.md`, the templates and the skills so they agree. Add new rules as new sections at the end, since the changelog cites section numbers.
2. Update `plugin/conventions/templates/agents-block.md` if agents need the rule. It loads in every session of every project, so add a line only if an agent would otherwise get it wrong.
3. A new skill also goes in `docs/user/skills.md` and the design's skill table.
4. For a convention change, increment `plugin/conventions/VERSION` and add a section at the top of `plugin/conventions/CHANGELOG.md`: `## v<N>: <summary>`, what changed and why, and `### Migration from v<N-1>`. The steps must work with work in progress, move content rather than delete it, and say where the user decides. Never change an earlier version's migration.
5. Bump `version` in `plugin/.claude-plugin/plugin.json`, or installed copies won't update. A convention change sets the major to the new `VERSION` and zeroes the rest. A skill change bumps the minor. A fix bumps the patch.

Keep every file as short as it can be. Skills, conventions and the block are loaded as context.

Run `just check` and commit with a subject that says what changed and why.

## 3. Apply it

If the change came from a project, suggest running `devkit:upgrade` there. Other projects learn of it from their next session's hook.
