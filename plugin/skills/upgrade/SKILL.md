---
name: upgrade
description: Bring a project up to the current devkit conventions by applying the changelog's migrations, or adopt devkit in a project that doesn't use it. Use when the session hook says the project is behind, or the user asks to upgrade or adopt devkit.
---

# Upgrade a project's conventions

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` and `${CLAUDE_PLUGIN_ROOT}/conventions/CHANGELOG.md` first. The current version is in `${CLAUDE_PLUGIN_ROOT}/conventions/VERSION`.

## 1. Find where the project stands

Read the `<!-- devkit:begin conventions=N -->` marker in `AGENTS.md`. With no marker the project is at v0, and this is an adoption. If N is current, say so and stop.

## 2. Plan

Collect the migrations from N+1 to the current version and work out what each step means here: which files move, which sections change, and what needs the user's judgment.

Check `git status`, and ask before touching docs with uncommitted changes. Show the user a short list of concrete changes and the questions that need answers, and wait for approval. A migration that only replaces the managed files can go ahead without asking.

## 3. Apply

1. Apply the approved steps in version order.
2. Replace the managed files. In `AGENTS.md`, replace everything from `<!-- devkit:begin` to `<!-- devkit:end -->` with `${CLAUDE_PLUGIN_ROOT}/conventions/templates/agents-block.md` for the current version. When adopting, add the block at the end, creating the file if needed. Copy `${CLAUDE_PLUGIN_ROOT}/conventions/templates/lint-docs.sh`, `${CLAUDE_PLUGIN_ROOT}/conventions/templates/fmt-docs.sh` and `${CLAUDE_PLUGIN_ROOT}/conventions/templates/check-commits.sh` into `.devkit/`, executable. Never edit text outside the block unless a migration step says to.
3. Fix links broken by moved files, in docs and code, and run `just check`.
4. Commit as `Upgrade to devkit conventions v<N>`, or `Adopt devkit conventions v<N>` from v0, with the trailer `Change: internal`. In team mode, commit on a branch and open a pull request, since the project's other users can't change files until it merges or they update the plugin.

Report what changed and what the user deferred. Suggest `devkit:audit` to catch drift no migration covers.
