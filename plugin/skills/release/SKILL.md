---
name: release
description: In a project that uses devkit, cut a release as an annotated version tag listing the user-visible changes since the last one. Use when the user asks to release, tag or ship a version.
---

# Release

Read `${CLAUDE_PLUGIN_ROOT}/conventions/CONVENTIONS.md` first, especially sections 3.3, 9 and 17.

1. **Start green.** The working tree is clean, the branch is `main` and current, and `just check` passes. If not, stop and report it.
2. **Gather the changes.** Read the trailers with `git log --format='%h%x09%(trailers:key=Change,valueonly)%x09%(trailers:key=Changelog,valueonly)' <last tag>..HEAD`. List the `Changelog:` sentences under headings for the `Change:` values in the order of section 17, and `ops` notes under a heading for operators. Drop `docs` and `internal` commits. For commits with no `Change:`, made before the project added the commit check, read their messages and keep the changes users see, in their words.
3. **Check the docs.** `docs/user/` describes every change kept, and no planned marker names a milestone the release claims to ship. Fix gaps with `devkit:user-docs` first.
4. **Pick the version** by semantic versioning from what changed, and set it in the one place the project keeps it. Ask if the bump isn't obvious.
5. **Tag.** Commit the version change with the trailer `Change: internal`, then create an annotated tag `v<version>` whose message lists the changes. Show the user the tag message, and push only when they say so.
6. **Outcomes.** If the PRD's success criteria can be checked once the release is in use, suggest an outcome review with `devkit:analysis`, or a plan task for when it can.
