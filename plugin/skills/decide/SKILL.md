---
name: decide
description: In a project that uses devkit, walk the user through open questions one at a time, researching each and recommending an answer, then write the answers into the docs. Use when the user asks to settle, answer or go through open questions, such as design Q3, or wants help making a decision.
---

# Decide

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 19 and 20. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

Before changing any file, compare the `conventions=N` marker in `AGENTS.md` with `${CLAUDE_PLUGIN_ROOT}/conventions/VERSION`. If the project is behind, stop, name both versions and offer `devkit:upgrade`. If the plugin is behind, stop and say to update the plugin.

1. **Gather the questions.** Take the ones the user names, such as design Q3, or the open questions of the doc they name: the PRD, `docs/ux.md`, the design, a proposal, or the plan's Decisions needed. With none named, say how many each doc has and ask which to take. A decision the user brings that is in no doc is one question.
2. **Order them** so that those others depend on come first.
3. **Take each to the user** as section 20 says, one at a time. Put the findings and the pros and cons in your message, then ask with the AskUserQuestion tool: one question per call, the recommended option first with "(Recommended)" in its label, and defer or spike as options when they fit. Say when an answer changes or settles a later question.
4. **Write the answers** once every question is answered, deferred or spiked, or the user stops.
   - A proposal's answers go into the proposal, and its settled questions are dropped.
   - Answers that change what the PRD, UX or design say are a decided change. Hand them to `devkit:design-review`, which writes them and drops the settled questions without asking them again.
   - An answer that changes no doc drops its question, with the reasoning in the commit body.
   - A spike becomes a plan task with `devkit:plan`, ahead of the work that depends on it. Its question stays open until the analysis settles it.
   - Deferred questions stay as they are.
5. Run `just check`. Solo, show the user the diff and commit on approval. In team mode, commit on a branch and open a pull request. The subject says what was decided, never a question's number, with the trailer `Change: docs`.
