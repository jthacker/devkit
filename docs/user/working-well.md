# Working well with devkit

These habits get the most out of devkit. [How work flows](workflow.md) covers the stages they fit into.

## Decide in the docs

Make decisions in reviewed doc changes, not in chat. Read the diff a design review produces. That diff is what agents build from. A wrong sentence there becomes wrong code later.

Say "accept the proposal" or "reject the proposal" when you decide. Claude rewrites the docs or records why not. Either way the proposal is deleted.

## Size the change

Ask for a proposal when you aren't sure yet. Go straight to a design review when you are sure but the work spans several tasks. Just ask for the change when it is small. Claude updates the docs in the same commit.

## Share a proposal by merging it

Claude reads only what is on main. Work on other branches isn't context. Merge a proposal when you want other sessions to see it. Merging it doesn't decide it.

## Ask why

Every requirement and design section has an ID, such as `design-7kq3`. Code and commits cite them. Ask Claude why a section says what it does. It reads the commits that cite the ID and tells you the reasons.

Cite IDs yourself too. "Implement M2.3" is clearer than describing the task.

## Reorganize the docs freely

Write a new section as a plain heading. Claude runs `just fmt`, which numbers it and gives it an ID. Move or merge sections whenever the docs read better. Links and citations keep working.

To cite a section in a comment, copy its ID from the doc's source. GitHub's link icon copies the heading's number instead. That number can change.

## Keep the plan current

Finish a milestone when its tasks are ticked. That removes its planned markers so the docs match the product. Drop planned work you no longer want in a design review. Stale planned sections mislead agents. An audit asks about milestones nobody has touched in 90 days.

## Bring outside talk back

Decisions made in meetings or chat don't reach agents on their own. Paste the outcome into a session. Claude puts it in a doc or a commit message.

## Fix bugs through the design

Report a bug in plain words. Claude writes a failing test first. If the design was wrong, it fixes the design too.

## Let devkit tell you when to upgrade

Claude says at the start of a session when a project is behind the conventions. Accept the upgrade when it is convenient. Ask for an audit afterwards to catch anything left over.

## Change a rule

Add a rule for one project to its `AGENTS.md`, outside the devkit block. To change the rules everywhere, see [Changing the conventions](forking.md).
