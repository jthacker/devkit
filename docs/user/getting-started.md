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

Claude asks for anything it can't work out. Then it creates the repo and drafts a PRD. It tells you what the PRD still needs from you.

## Choose where projects go

New projects go next to the project you are in. To put them somewhere else, set `DEVKIT_PROJECTS_DIR` in your Claude Code user settings. Open `~/.claude/settings.json` and add it under `env`.

```json
{
  "env": {
    "DEVKIT_PROJECTS_DIR": "/Users/you/code"
  }
}
```

Use the full path, since `~` is not expanded here. If the file already has an `env` section, add the line to it. Start a new session so the setting loads.

## Get updates

Run these in a terminal to fetch a new version.

```sh
claude plugin marketplace update devkit
claude plugin update devkit@devkit
```

Start a new session to load it. When a project falls behind the conventions, Claude says so and offers to upgrade it. Nothing changes until you agree.

## Use devkit in an existing project

Ask Claude to adopt devkit. It lists what it would change and waits for your approval.
