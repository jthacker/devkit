# Getting started

## Install

Run these in Claude Code.

```
/plugin marketplace add jthacker/devkit
/plugin install devkit@devkit
```

Start a new session so the plugin loads.

## Start a project

Ask Claude in plain words.

```
Start a new project called recipes that stores my recipes as Markdown files.
```

Claude asks where to put the project. It suggests a folder next to the project you are in. It also asks for anything else it can't work out. Then it creates the repo and drafts a PRD. It tells you what the PRD still needs from you.

## Get updates

Run these in a terminal to fetch a new version.

```sh
claude plugin marketplace update devkit
claude plugin update devkit@devkit
```

Start a new session to load it. When a project falls behind the conventions, Claude says so and offers to upgrade it. Nothing changes until you agree. Until then, Claude won't change files in that project.

## Use devkit in an existing project

Ask Claude to adopt devkit. It lists what it would change and waits for your approval.
