---
description: Commit all changes, create a PR, and merge into the default branch
argument-hint: "[base-branch]"
---

Commit all changes, create a PR, and merge into the default (or specified) base branch.

**Input**: Optionally specify a base branch (e.g., `/shipit main`, `/shipit develop`). If omitted, detect the default branch.

**Provided arguments**: $@

## Steps

1. **Identify the base branch**

   If provided as an argument, use it. Otherwise detect from git/gh:
   ```bash
   git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@.*/@@'
   gh repo view --json defaultBranch --jq .defaultBranch 2>/dev/null
   ```
   If detection fails, ask the user which branch to target.

2. **Check working state**
   ```bash
   git status
   git diff
   git log "$BASE_BRANCH..HEAD" --oneline
   ```
   - If there are no changes and no unpushed commits, tell the user there's nothing to ship and stop.

3. **Check for associated OpenSpec change**

   Derive the workspace name from the current working directory:
   ```bash
   basename "$(pwd)"
   ```

   Check if a matching tasks file exists:
   ```bash
   test -f "openspec/changes/<workspace_name>/tasks.md" && echo found || echo not found
   ```

   **If no tasks file found:** Skip to step 4.

   **If tasks file found:**

   Count incomplete vs complete tasks:
   ```bash
   grep -c '^- \['"'"' \]' "openspec/changes/<workspace_name>/tasks.md" || true
   grep -c '^- \[x\]' "openspec/changes/<workspace_name>/tasks.md" || true
   ```

   **If incomplete tasks exist:**
   - Extract and display each incomplete task line (the `- [ ] ...` lines), grouped by their nearest `##` section heading
   - Announce clearly: "⚠️ X incomplete task(s) remain in the OpenSpec change `<name>`:" followed by the list
   - Continue to step 4 (do not block shipping on incomplete tasks)

   **If all tasks are complete (zero `- [ ]` lines):**
   - Announce: "✓ All tasks complete in OpenSpec change `<name>`."
   - Use **AskUserQuestion tool** to ask: "All OpenSpec tasks are complete. Archive the `<name>` change before shipping?"
   - If user says **yes**: invoke `/skill:openspec-archive-change` for change `<name>`, wait for it to complete, then continue to step 4.
   - If user says **no**: continue to step 4.

4. **Stage and commit any uncommitted changes**
   - If there are uncommitted changes, stage and commit them.
   - Write a concise commit message describing what changed and why.
   - If there are already commits ahead of the base branch but no uncommitted changes, skip this step.

5. **Push the branch**
   ```bash
   git push -u origin HEAD
   ```

6. **Create a PR**

   Detect the remote repository (omit `--repo` to let `gh` infer from origin):
   ```bash
   gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || echo "<remote>"
   ```

   Write a PR body to a temp file and use `--body-file`:
   ```bash
   tmp_body="$(mktemp)"
   cat > "$tmp_body" <<'EOF'
   ## Summary
   - <bullet points>

   ## Testing
   - <what was verified>
   EOF

   gh pr create \
     --base "$BASE_BRANCH" \
     --head "$(git branch --show-current)" \
     --title "<title>" \
     --body-file "$tmp_body"
   rm -f "$tmp_body"
   ```

7. **Ask for merge approval then merge**

   - Use **AskUserQuestion tool** to ask: "Merge the PR into `$BASE_BRANCH`?"
   - If approved, ask which merge strategy to use:
     ```bash
     gh pr merge "$PR_URL" --delete-branch --<strategy>
     ```
     Common strategies: `--squash`, `--rebase`, `--merge`. If unsure, prefer `--squash`.
     - If the user said nothing specific, use the merge strategy suggested by the repo's default settings (detect via `gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed`).
   - If the user rejects, stop and report.

8. **Report the result** — print the PR URL and confirm it was merged.

## Guardrails
- Never force-push.
- Never skip hooks (`--no-verify`).
- If any step fails, stop and report the error rather than continuing.
- Never merge automatically — always ask for explicit approval before merging (step 7).
- Prefer stopping and asking a focused question over making assumptions about branch targets or merge strategy.
- Let `gh` infer the remote repository from the git origin — do not hardcode a repo.
- Detect the base branch dynamically; do not assume `master` or `main`.
