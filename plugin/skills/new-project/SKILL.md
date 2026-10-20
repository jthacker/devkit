---
name: new-project
description: Start a new project with the devkit conventions, creating the repo, AGENTS.md, justfile and docs skeleton, then drafting the PRD. Use when the user asks to start, create or bootstrap a project, or to graduate an idea into one.
---

# Start a new project

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first. Templates are in `${CLAUDE_PLUGIN_ROOT}/conventions/templates/`, and the current version is in `${CLAUDE_PLUGIN_ROOT}/conventions/VERSION`.

## 1. Gather what's needed

- **Name** and **slug**, lowercase kebab-case, naming the directory.
- **Pitch**: one or two sentences on what it is and why it matters.
- **Location**: from the request if it names one, with no spaces. Otherwise ask for it, suggesting `<parent>/<slug>` where the parent is the directory holding the current directory's git repo, if there is one.
- **Source idea**: an idea doc the user points to, if one exists. It is the PRD's starting point.
- **Stack**, if the user knows it yet.
- **Mode**: solo, the default, or team, where changes go through reviewed pull requests.
- **Repos**: whether it is one repo, a component of a product that has a product repo, or the product repo itself. A product repo holds the PRD, UX and cross-repo design, and its code lives in the component repos.

Ask once for the location and anything else you can't work out. Confirm the name and location before creating anything. If the directory exists and isn't empty, stop and ask.

## 2. Create the skeleton

1. Create the directory and run `git init -b main`.
2. Copy the templates, filling every `{{UPPERCASE}}` placeholder. Other double-brace text, such as `{{source_file()}}`, stays as it is.
   - `AGENTS.md`, with `{{DEVKIT_BLOCK}}` replaced by `agents-block.md` for the current version.
   - `CLAUDE.md`, `justfile`, `docs/README.md`, `docs/prd.md`, and `gitignore` as `.gitignore`.
   - `README.md`, with the pitch as the one-line `{{SUMMARY}}` and `{{WHY}}` as a few sentences on what changes for its users compared with today. `{{START}}` follows section 10, which before there is anything to use is one line saying so.
   - `lint-docs.sh`, `fmt-docs.sh` and `check-commits.sh` in `.devkit/`, executable.
   - For team mode, a line in `AGENTS.md` outside the block saying the project is in team mode, and a `CODEOWNERS` file suggesting doc owners by role, with placeholders for the user to fill.
   - For a product or component repo, a `## Related repos` section in `AGENTS.md` outside the block, listing each related repo's short name, role and clone URL (CONVENTIONS section 15).
3. Leave the UX, design, plan, proposals, analyses and user docs until there is something to put in them.
4. A product repo has no stack, so skip this step. If the stack is known, add a first component with the stack's own starter, such as `cargo init` or `uv init`, so it builds and passes its tests from the first commit. Give it a justfile per section 7, add a `mod` line and the aggregating root recipes, and add the root `fmt`, `run`, `setup` and `install` recipes that apply. Add the stack's ignores to `.gitignore`. Write no application code beyond the starter's.
5. Run `just check` and fix the skeleton until it passes, or tell the user what's missing, such as a toolchain.

## 3. Graduate the idea, if there is one

If the idea doc's repo has graduation steps in its `AGENTS.md`, follow them. Link the idea doc from the README.

## 4. Draft the PRD

Draft `docs/prd.md` with `devkit:prd` from the pitch, the idea doc and the conversation. Put unknowns under Open questions rather than inventing detail. Run `just fmt` to number its sections and give its requirements IDs.

## 5. Commit and hand off

Commit as `Start <name> with devkit conventions v<N>`, with the trailer `Change: internal`. Tell the user where the project is, what the PRD needs from them, and that the design comes next with `devkit:design`.
