# /shipit

Use this command when the current branch is ready for finalization and you want an OpenSpec-aware path from local changes to PR and merge.

## Workflow

1. Inspect the current worktree before doing anything destructive:
   - review `git status` and the staged/unstaged diff
   - identify the current branch and the repository's default branch

2. Check whether the worktree contains any OpenSpec task lists:
   - look for `openspec/changes/**/tasks.md`
   - for each file, identify unfinished checklist items such as `- [ ] ...`

3. If any OpenSpec `tasks.md` file still has unfinished items:
   - show the user each affected `tasks.md` path
   - list the unfinished items grouped under that file
   - explain that OpenSpec work is still marked incomplete
   - explicitly ask whether you should continue anyway with the release flow
   - do **not** continue until the user gives a clear yes

4. If OpenSpec task files exist and all checklist items are complete:
   - sync the accepted change into the canonical OpenSpec specs using the repository's normal OpenSpec workflow
   - archive the completed OpenSpec change before preparing the PR
   - summarize what was synced and archived
   - if the repository does not provide the needed OpenSpec tooling or instructions, pause and tell the user exactly what is missing instead of guessing

5. If no OpenSpec `tasks.md` files are present, continue with the standard finalization flow.

6. Finalization flow after any required confirmation or OpenSpec sync/archive work:
   - confirm the commit scope with the user if it is ambiguous
   - commit the current changes
   - push the branch to the remote
   - create a pull request targeting the default branch
   - monitor PR checks until they finish or until you hit a reasonable wait limit
   - report the status of each check and call out any failures or blockers

7. After reporting PR status, ask the user whether to merge into the default branch.
   - never merge without explicit approval
   - if checks are failing or branch protection blocks merge, explain the blocker clearly

## Guardrails

- Never hide unfinished OpenSpec tasks from the user.
- Never mark tasks complete unless the underlying work is actually done.
- Never merge automatically.
- Prefer stopping and asking a focused question over making assumptions about OpenSpec tooling, branch targets, or merge strategy.
