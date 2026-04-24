# agentic-coding-skills

A collection of `SKILL.md` files for use with agentic coding systems. Each skill is a standalone instruction file you can load into an AI-assisted development workflow to give the model a specific role with a clear operating procedure.

These skills are intentionally:
- **Platform agnostic**: usable in local CLIs, editor agents, web chat UIs, or automation pipelines
- **Provider agnostic**: usable with Anthropic, OpenAI, GitHub-hosted models, or other capable LLMs
- **Model agnostic**: best with strong reasoning models, but not tied to a single model family

---

## Available Skills

| Skill | Description |
|---|---|
| [adversarial-review](./adversarial-review/SKILL.md) | Have a fresh AI model conduct a skeptical, adversarial review of PRs from any workflow, with explicit guidance for reviewing OpenSpec artifacts when they are part of the change. |
| [architecture-planning](./architecture-planning/SKILL.md) | Guide an AI through structured technical planning before any code is written — producing a clear spec, decision log, and implementation checklist for a strong implementation model to follow. |
| [security-audit](./security-audit/SKILL.md) | A focused security-only review that checks for injection, auth gaps, secrets exposure, insecure dependencies, and other OWASP-class vulnerabilities. |
| [test-generation](./test-generation/SKILL.md) | Drive an AI to generate comprehensive test suites — covering unit, integration, edge-case, and regression scenarios — rather than just happy-path tests. |
| [refactoring-guide](./refactoring-guide/SKILL.md) | Systematically improve code quality without changing behavior: remove duplication, improve naming, simplify logic, and modernize patterns. |
| [dependency-audit](./dependency-audit/SKILL.md) | Review newly added or updated dependencies for known vulnerabilities, unnecessary scope, license issues, and maintenance health. |
| [performance-review](./performance-review/SKILL.md) | Profile and critique code for latency, throughput, and resource usage bottlenecks. Includes common AI failure modes like N+1 queries and unnecessary re-computation. |
| [documentation-writer](./documentation-writer/SKILL.md) | Generate accurate, consistently styled documentation (README, API docs, inline comments) that matches the conventions of an existing codebase. |
| [onboarding-guide](./onboarding-guide/SKILL.md) | Analyze a codebase and produce a structured guide for new developers: architecture overview, key entry points, data flow, gotchas, and local setup instructions. |
| [migration-assistant](./migration-assistant/SKILL.md) | Plan and execute database or API migrations safely — generating rollback strategies, compatibility shims, and step-by-step execution plans. |
| [incident-review](./incident-review/SKILL.md) | Conduct a blameless post-mortem on a production incident: establish a timeline, identify contributing causes, and produce actionable follow-up items. |
| [support-engineer](./support-engineer/SKILL.md) | Investigate user-reported issues, identify the underlying cause, recommend engineering fixes, and draft a clear response for the affected end user. |
| [create-agents-file](./create-agents-file/SKILL.md) | Create or refresh a repository-specific `AGENTS.md` file with accurate setup, workflow, testing, and stack-aware agent guidance. |

---

## Using These Skills in an Agentic Development Environment

The core pattern is the same no matter which tool, provider, or model you use:

1. **Choose a skill** based on the job you want the agent to perform.
2. **Place the skill in the tool's native skills directory** so the agent can discover it natively.
3. **Start a fresh session** in the target repository.
4. **Provide working context** such as a task description, issue, diff, file set, repository path, design doc, or PR link.
5. **Tell the agent what to do next** such as review, plan, implement, critique, or summarize.

### What makes a skill work well

Skills are most effective when you:
- use a **fresh model or fresh session** for the skill when possible
- provide **real artifacts** instead of vague summaries
- give the agent a **single clear objective**
- use one skill for one main role at a time

### Recommended prompt pattern

Use this general structure in any agentic environment:

1. Reference the installed skill by name
2. Add task-specific context
3. Give a direct instruction

Example:

```text
Use the adversarial-review skill for this session.

Context:
- Repository: <repo or local path>
- Task: <what changed or needs to be done>
- Artifacts: <diff, PR, issue, design doc, logs, etc.>

Now perform the task using that skill.
```

---

## Platform-Specific Examples

The wording below is intentionally concrete, but the same pattern works in any comparable tool.

### Claude Code

Use when you want a terminal-based coding agent to inspect a repo, diff, or working tree directly.

Example flow:

1. Create `.claude/skills/adversarial-review/` in your repo (or in `~/.claude/skills/` for a global install).
2. Copy this repo's `adversarial-review/SKILL.md` to `.claude/skills/adversarial-review/SKILL.md`.
3. Start a new Claude Code session in your repository.
4. Invoke the skill in your task prompt:

```text
Use the adversarial-review skill.
Review the current branch.
Compare the working tree against the main branch.
Focus on correctness, security, test quality, and scope creep.
```

Note: Claude skill discovery is based on `.claude/skills` paths; a shared `.agents` directory is not discovered automatically.

Good fit:
- reviewing a local branch before opening a PR
- reviewing unstaged or staged changes
- checking whether implementation matches an issue or spec

### OpenAI Codex

Use when you want a coding agent to operate on a repository with explicit task instructions.

Example flow:

1. Create `.codex/skills/adversarial-review/` in your repo (or in `~/.codex/skills/` for a global install).
2. Copy this repo's `adversarial-review/SKILL.md` to `.codex/skills/adversarial-review/SKILL.md`.
3. Start a fresh Codex session for the repository.
4. Invoke the skill with your repo-specific task:

```text
Use the adversarial-review skill to review the changes for the current task.
Inspect the modified files, identify defects and risky assumptions, and give a verdict.
Use the issue description and local diff as the source of truth.
```

Good fit:
- code review before commit
- review of generated code from another agent
- repo-aware critique with file-level findings

### GitHub Copilot CLI

Use when you want to drive an agentic workflow from the terminal and provide diffs or files directly.

Example flow:

1. Open the skill file locally
2. Start a new Copilot CLI chat or agent session
3. Paste the skill contents
4. Provide a concrete instruction, for example:

```text
Use this skill to review the output of the last implementation step.
Look at the current git diff and the files that changed.
Report critical issues, significant concerns, minor issues, questions, and a final verdict.
```

Good fit:
- quick local review loops
- validating agent-generated edits before commit
- applying a repeatable review role in shell-driven workflows

### GitHub Copilot Web UI

Use when you want to review a PR, issue, design note, or pasted diff in the browser.

Example flow:

1. Open a new chat in GitHub Copilot
2. Paste the `SKILL.md` contents into the first message
3. Attach or paste the relevant PR description, diff, issue text, or spec excerpts
4. Ask Copilot to perform the task, for example:

```text
Use this skill to review this pull request.
Check whether the implementation matches the PR description and whether there are correctness, security, or testing gaps.
If the PR references planning artifacts, review those too.
```

Good fit:
- PR review in GitHub
- reviewing issues, specs, and design artifacts without local checkout
- sharing a reusable review workflow with a team

---

## Practical Tips

- Prefer **new sessions** over continuing an unrelated conversation
- If the tool supports it, put the skill in a **system prompt**, **custom instruction**, or **chat preamble**
- If the tool does not support system prompts, put the skill in the **first user message**
- When reviewing code, include the **issue**, **diff**, and **tests** whenever possible
- When planning work, include the **requirements**, **constraints**, and **acceptance criteria**
- If you switch models mid-workflow, **reload the skill** instead of assuming prior instructions carry over

---

## Usage Summary

1. Open the `SKILL.md` file for the skill you want to use.
2. Copy it into your target tool's native skills directory (for example, `.claude/skills/...` or `.codex/skills/...`).
3. Start a fresh session for your repository.
4. Provide the relevant context and ask the agent to execute the task with that skill.

Skills are intentionally standalone and portable across tools, but each provider has its own discovery path conventions.
