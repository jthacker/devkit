# devkit: Product requirements

devkit gives every project one lightweight process for product development, kept in its repo. Changes to the requirements, UX and design get the same review, history and tracing as changes to code. The people who own each part of the product and the agents that assist them work from the same current docs.

## 1. Problem <a id="prd-2cvv"></a>

Code has the tools to change safely: review, history, blame and tests. The rest of product development rarely does. Agents now write much of the code and docs, so requirements, UX and design change fast too. Without the same tools, that speed exposes problems slower teams could absorb:

- **Every project is different.** Each one lays out its docs, plans, commits and tooling its own way. People and agents relearn each project before they can work in it. Every new project starts by teaching an agent the rules again. Good practice found in one project stays there.
- **Experts work apart.** Product, design, engineering, writing and operations each use their own tools and vocabulary. Handoffs lose context. Review happens in some places and not others. Each expert's agent sees only what that person gives it.
- **Agents start without context.** Each session begins empty. A person re-explains whatever the agent can't find written down, or the agent guesses. Guesses become code.
- **Work is split across tools.** Requirements sit in a doc tool, screens in a design tool, tasks in a tracker, decisions in chat and code in git. Each holds part of the picture and none links to the others. An agent sees only the repo.
- **Change is either heavy or invisible.** Review boards and ticket workflows can't keep pace with agents. Without them, decisions happen implicitly in code. No one can tell what was decided, what is built and what is only planned.
- **Nothing traces.** From a line of code there is no path back to the requirement or decision behind it. From a requirement there is no path forward to the code, tests and user docs that serve it.
- **History is lost.** Requirements and design decisions have no blame. The reason something works the way it does lives in a thread or someone's memory.
- **Docs trail the change.** Teams write docs after the code, if at all, as a chore they skip under pressure. Docs drift from what was built. Stale docs mislead agents more than missing ones.

Agents make docs cheap to write. Two things are missing. One is a standard for which docs a project keeps and what goes in each. The other is a process that changes them with the same care as code, as part of every change rather than after it.

## 2. Users <a id="prd-d3f2"></a>

devkit serves people and agents working together. People are the experts. They own a part of the product, make its decisions and review changes to it. Agents are their assistants. They research, draft, build and keep the docs current, and they bring each change to the right person to decide.

The people are product managers, designers, engineers, writers and operators. On a team each role is a different person, and some review and comment without using git. The primary user today is a developer who runs several projects at once and plays every role. Agents do most of their writing. The maintainer is one such user and also changes the conventions.

The agents need to find the right doc, know what is built and what is only planned, and know where new material goes, without being told each session.

## 3. Approach <a id="prd-88c1"></a>

A Claude Code plugin that holds conventions, templates and skills in one repo.

**People decide, agents assist.** Each role has a home in the repo. Each kind of change goes to the people who own it, such as designers for UX. Agents write the drafts, proposals, design reviews and code. People approve them as diffs, the same way for every role. People who don't use git review in the browser or through an agent, and their decisions land in the repo. Every role works from the same docs, so an agent assisting one expert sees what the others decided.

**One standard.** Every project has the same docs in the same places, the same ID scheme, the same commit format and the same `just` recipes, whatever its language or domain. A person or agent who knows one devkit project knows where to look in any other. A linter checks the parts that can be checked mechanically.

**The repo is the record.** Each role has a doc in the project's repo: the PRD for what and why, UX for how people experience it, the design for how it works, the plan for what is left, analyses for evidence and user docs for how to use it. These docs change the way code does, through reviewed diffs. Main holds the reviewed state of the whole product, and git holds how it got there. An agent starts at `AGENTS.md` and follows links to what it needs.

**Change is lightweight.** An idea goes under Later in the plan. A change that needs an argument becomes a proposal. A decided change is one design review, reviewed as a single diff. It rewrites the docs as they will read once built, marks unbuilt sections planned and adds the plan tasks. Commits that implement it cite its IDs. Finishing a milestone removes its planned markers. A release lists what users will notice, and an outcome review checks the success criteria. Each step has a skill, so an agent does the paperwork and a person makes the decisions.

**Everything is traceable.** Requirements, UX sections, design sections and plan tasks have stable IDs. Code comments, commits and docs cite them. A reader can go from code to the decision behind it, or from a requirement to everything that serves it. `git log --grep` on an ID gives a section its history. Each commit also says what kind of change it is, so readers can filter history and releases draw their notes from it.

**Docs come with the change.** A decided change goes into the docs before anyone builds it. A commit holds its code, tests and docs together. A milestone isn't done until the user docs, UX and design describe what was built. Each doc type has a template and a skill that writes it to the same bar. Quality doesn't depend on who or what wrote it.

**The conventions evolve.** The conventions carry a version, and each project records the version it follows. A hook tells a project when it is behind. Each version has a migration that brings a project up to date.

## 4. Goals and success criteria <a id="prd-kx4h"></a>

1. **Start a project in one request.** <a id="prd-gfx8"></a><a id="R1"></a> "Start a new project called X that does Y" produces a committed repo with a draft PRD and the open questions to answer, with no other setup.
2. **One format.** <a id="prd-830w"></a><a id="R2"></a> Every doc type has one template and one set of rules, and the skills follow them without being reminded.
3. **Agents know the rules without the plugin.** <a id="prd-68zv"></a><a id="R3"></a> A project's `AGENTS.md` carries a summary of the conventions, so agents that don't load Claude Code plugins follow them too.
4. **Conventions evolve in one place.** <a id="prd-by6e"></a><a id="R4"></a> Changing a convention takes one edit in the devkit repo, and new projects get it immediately.
5. **Existing projects catch up on request.** <a id="prd-a19r"></a><a id="R5"></a> When a project falls behind, its next session says so and lists what changed. The project can upgrade in one step. Nothing changes without the user's approval.
6. **Existing projects are untouched until adopted.** <a id="prd-4svd"></a><a id="R6"></a> A project that doesn't use devkit sees no hook output and no changes.
7. **One way of working.** <a id="prd-27en"></a><a id="R7"></a> Implementing a task, fixing a bug, committing, testing, adding a dependency and keeping secrets follow the same steps in every project, whatever its language, libraries or domain.
8. **Drift is visible.** <a id="prd-5j7p"></a><a id="R8"></a> On request, devkit finds a project's departures from the current conventions. `just lint` checks some of them.
9. **Anyone can install it.** <a id="prd-25zb"></a><a id="R9"></a> devkit installs from GitHub in two commands and updates when its conventions change. Someone who wants different conventions can fork it and change the fork. Nothing in it assumes one person's directories.
10. **Lightweight change management in the repo.** <a id="prd-8z7e"></a><a id="R10"></a> Every stage from an idea to checking whether it worked has a home in the repo and a skill: proposals, design review, planned and built specs for each role, plan, code, release, incidents and outcome reviews. Main holds the reviewed state of all of it, and git holds how it got there.
11. **Any team size.** <a id="prd-77ak"></a><a id="R11"></a> One structure serves a person playing every role and a team with a person per role. A solo project writes less, and a team adds review, with no change of layout between them. It also works across several repos that make up one product.
12. **The repo is all an agent needs.** <a id="prd-5h1g"></a><a id="R12"></a> Starting from `AGENTS.md`, an agent finds the context for any stage by following links, IDs and git history. It can tell what is built from what is planned, and it loads only what its stage needs.
13. **Feedback without git.** <a id="prd-kb8q"></a><a id="R13"></a> People who don't use git can review and comment, and what their feedback decides lands in the repo.
14. **Only the lifecycle.** <a id="prd-a6kk"></a><a id="R14"></a> Every skill devkit ships produces, updates or depends on a lifecycle doc. devkit leaves general coding advice and views across projects to other tools. The skills that maintain devkit itself live in its repo.
15. **History by kind of change.** <a id="prd-6v2e"></a><a id="R15"></a> Every commit says what kind of change it is. Each reader filters history to what they care about with git alone. A release's notes come from the commits, in words users read.
16. **Docs current with the code.** <a id="prd-2c17"></a><a id="R16"></a> A commit holds its code, tests and docs together. A finished milestone leaves no planned markers, and its user docs, UX and design describe what was built.
17. **Every change traces.** <a id="prd-x3qg"></a><a id="R17"></a> Using IDs and git alone, a reader goes from any requirement, UX or design section to the commits, code and plan tasks that cite it. From any commit or cited code, they find the sections behind it. `just lint` finds citations to sections that don't exist, in docs and code. Reorganizing a doc never breaks a citation.

## 5. Non-goals <a id="prd-f08m"></a>

- Scaffolding application code or picking a stack. devkit sets up docs and tooling structure. The stack is the project's decision.
- Rules for a particular language, library or domain. Those belong to the project.
- Supporting agents other than Claude Code beyond what `AGENTS.md` gives them.
- General coding advice and views across projects. devkit covers the steps that produce or depend on docs.

## 6. Open questions <a id="prd-4dvg"></a>

None yet.
