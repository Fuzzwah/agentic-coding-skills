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

### Install with the script (recommended)

Run this from the root of the target repository:

```bash
curl -fsSL https://raw.githubusercontent.com/Fuzzwah/agentic-coding-skills/main/install-skills.sh | bash
```

If you want to inspect the script first, download it, review it, then run it locally instead.

The installer will:
- detect existing `.claude`, `.github`, `.codex`, and `.opencode` markers in the current project
- prompt you to confirm or change which platforms you want to install for
- prompt you to install specific skills or **all**
- install the selected skills into the native project paths:
  - Claude Code: `.claude/skills/<skill>/SKILL.md`
  - OpenAI Codex: `.codex/skills/<skill>/SKILL.md`
  - GitHub Copilot: `.github/skills/<skill>/SKILL.md`
  - OpenCode: `.agents/skills/<skill>/SKILL.md`

### Manual installation

If you prefer to copy files yourself instead of using the installer, use the manual flow below.

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

### Platform-specific manual installation

The wording below is intentionally concrete, but the same pattern works in any comparable tool.

#### Claude Code

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

#### OpenAI Codex

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

#### GitHub Copilot

Per the official GitHub docs, agent skills work with **Copilot cloud agent**, **GitHub Copilot CLI**, and **agent mode in Visual Studio Code**.

Use when you want GitHub Copilot to discover these skills natively instead of pasting the `SKILL.md` contents into chat.

Example flow:

1. Choose whether you want a **project skill** or a **personal skill**:
   - Project skill for this repo only: create `.github/skills/adversarial-review/` in the repository
   - Personal skill across repos: create `~/.copilot/skills/adversarial-review/`
2. Copy this repo's entire `adversarial-review/` directory into that location so the installed folder contains `SKILL.md`.
3. Keep the skill folder name lowercase and hyphenated, and keep the file name exactly `SKILL.md`.
4. Start a fresh Copilot session in the repository using Copilot cloud agent, GitHub Copilot CLI, or VS Code agent mode.
5. Give Copilot a task that matches the skill, plus the relevant context. You can mention the skill explicitly if you want, but Copilot can also choose it automatically from the skill description.

Example prompt:

```text
Use the adversarial-review skill for this task.
Review the current branch against the main branch.
Focus on correctness, security, test quality, and scope creep.
```

If you want to install skills with GitHub CLI instead of copying folders manually, GitHub's official docs also support `gh skill install`, `gh skill preview`, and `gh skill update`.

Good fit:
- repo-scoped skills in Copilot cloud agent
- personal skill libraries shared across repositories
- repeatable workflows in Copilot CLI or VS Code agent mode

#### OpenCode

Use when you want [opencode](https://opencode.ai) to discover skills from your project or your home directory.

OpenCode scans for skills in `.claude/` and `.agents/` directories, using `skills/**/SKILL.md` as the discovery pattern. The `.agents/skills/` path is the recommended destination to avoid overlap with Claude Code's `.claude/skills/`.

Example flow:

1. Create `.agents/skills/adversarial-review/` in your repo (or in `~/.agents/skills/` for a global install).
2. Copy this repo's `adversarial-review/SKILL.md` to `.agents/skills/adversarial-review/SKILL.md`.
3. Start a fresh opencode session in the repository.
4. Invoke the skill in your task prompt:

```text
Use the adversarial-review skill.
Review the current branch against the main branch.
Focus on correctness, security, test quality, and scope creep.
```

Note: opencode discovers skills from both `.claude/skills/` and `.agents/skills/` within the project tree, so skills installed for Claude Code are also available to opencode automatically.

Good fit:
- terminal-based coding sessions with opencode
- sharing skills across both Claude Code and opencode in the same project

---

## Practical Tips

- Prefer **new sessions** over continuing an unrelated conversation
- If the tool supports it, put the skill in a **system prompt**, **custom instruction**, or **chat preamble**
- In GitHub Copilot, prefer installing the skill in `.github/skills` or `~/.copilot/skills` instead of pasting the file into chat
- When reviewing code, include the **issue**, **diff**, and **tests** whenever possible
- When planning work, include the **requirements**, **constraints**, and **acceptance criteria**
- If you switch models mid-workflow, **reload the skill** instead of assuming prior instructions carry over

## Usage Summary

1. Open the `SKILL.md` file for the skill you want to use.
2. Copy the skill folder into your target tool's native skills directory (for example, `.github/skills/...`, `~/.copilot/skills/...`, `.claude/skills/...`, `.codex/skills/...`, or `.agents/skills/...`).
3. Start a fresh session for your repository.
4. Provide the relevant context and ask the agent to execute the task with that skill.

Skills are intentionally standalone and portable across tools, but each provider has its own discovery path conventions.
