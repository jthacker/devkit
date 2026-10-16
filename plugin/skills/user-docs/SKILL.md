---
name: user-docs
description: In a project that uses devkit, write or update end-user docs in docs/user/. Use when the user asks for user docs, a guide, how-to, reference or troubleshooting page, or when behavior users see has changed.
---

# User docs

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 4.1 and 10. The index template is `${CLAUDE_PLUGIN_ROOT}/conventions/templates/docs/user/README.md`. If `AGENTS.md` has no `devkit:begin` block, the project doesn't use devkit, so ask before applying its structure.

User docs describe the product as it behaves now, for the people who use it. No internals unless a user needs them, no plans, and nothing from a planned section until it ships.

## Pages

`docs/user/README.md` lists every page in a table. Pages follow what the reader is trying to do:

- `getting-started.md` goes from nothing to the first useful result, with every command.
- A task page per job, named for it, such as `backups.md`. Steps first, explanation after.
- Reference pages for what is looked up: commands, settings, file formats. Generate them from the code when the code is the source of truth, and say how in a comment at the top.
- `troubleshooting.md` has symptoms as headings, each with cause and fix. Give an entry an `<a id="...">` anchor when the product links to it.

With distinct audiences, such as hosts and players, prefix page names with the audience.

## Writing

- Second person, present tense: "Run `x`. It prints ...". Show the output a reader should expect.
- Check every command and example against the real behavior, running it when you can.
- Link to other pages rather than repeating them.
- Update the pages in the same commit as the behavior.
- When the steps to start change, update the README's Start part too, keeping it to the fewest steps and linking to `getting-started.md`. When `docs/user/` is first created, link it from the README's More part.
