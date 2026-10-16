# Changing the conventions

The conventions come from the installed plugin. An update replaces it, so Claude won't edit the installed copy.

## For one project

Ask Claude to add the rule to the project. It goes in the project's `AGENTS.md`, outside the block devkit manages. Upgrades leave it alone.

## For all your projects

Fork devkit on GitHub and clone your fork. Remove the GitHub install, then install from your clone.

```sh
claude plugin uninstall devkit@devkit
claude plugin marketplace remove devkit
cd devkit
just install
```

This needs `just` and `shellcheck`. `just install` stops if the GitHub install is still there. The plugin now loads from your clone.

To change a convention, start Claude in your clone. Then ask for the change. Claude edits your fork. Every project sees the change in its next session.

Changes that would help everyone are welcome as pull requests.
