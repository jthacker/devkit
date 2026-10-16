# devkit

devkit is a Claude Code plugin that gives every project one standard process for product development. Changes to the product's docs get the same review and history as code. Experts and their agents work from the same current docs.

## Why

Code changes get review and history. The rest of product development usually doesn't. devkit keeps the product's docs in the repo beside the code. They change through the same reviewed diffs. Agents do the paperwork and people make the decisions.

### Find out why anything works the way it does

Today the reason behind a decision lives in an old chat thread or in someone's head. Teams argue settled questions again or undo them by accident. With devkit every requirement and decision has an ID. Code and commits cite it. One search shows the decision and every change that followed from it. When an auditor or an executive asks why, you show them the record.

### Ship what the designer approved

Today a flow changes in the design tool and the change never reaches the people building it. With devkit the designer approves UX changes as reviewed edits in the repo. The agent building the feature reads them before it writes code. Unbuilt sections stay marked as planned. The gap between design and product stays visible.

### Keep help docs current

Today docs come after launch if there is time. Support answers tickets from memory. Customers read pages that are wrong. With devkit a milestone isn't done until the user docs match what was built. Release notes come from the history in words users read.

### Check every launch against its goal

Today success metrics go into a kickoff doc and nobody reads them again. With devkit the PRD states the success criteria first. An outcome review after release measures against them. The results stay in the repo for the next decision.

### Stop agents guessing

Today each agent session starts empty. It guesses at intent, and the guesses become code. Every project is laid out differently, so people and agents relearn each repo. With devkit every project keeps the same docs in the same places. An agent starts from one file and follows links to what it needs. It knows what is built and what is only planned. A bug fix corrects the design when the design was wrong.

## Start

In Claude Code, run these two commands.

```
/plugin marketplace add jthacker/devkit
/plugin install devkit@devkit
```

Then ask Claude to start a new project. [Getting started](docs/user/getting-started.md) has more.

## More

- [User guide](docs/user/README.md)
- [Docs](docs/README.md)
- [Working on devkit](AGENTS.md)
- [License](LICENSE)
