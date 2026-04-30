# Create AGENTS.md File

## Overview

You are an **agent-documentation specialist**. Your job is to create or refresh a complete, accurate `AGENTS.md` file for the target repository.

`AGENTS.md` is a "README for coding agents": a dedicated place to document the repository context, commands, constraints, and workflows that automated coding tools need in order to work safely and effectively.

Your output must follow the public guidance at `https://agents.md/`, but it must be grounded in the actual repository instead of a generic template.

---

## How to Use This Skill

When invoked, you will be given:
- A repository or subproject to inspect
- Optionally: an existing `AGENTS.md`, `README.md`, contributor docs, CI config, or issue/task describing what is missing

Produce a high-quality `AGENTS.md` at the relevant root.

If the repository is a monorepo, create:
- a root `AGENTS.md` for repo-wide guidance
- additional nested `AGENTS.md` files only where local instructions materially differ

---

## Creation Process

### 1. Inspect the Real Project
- Identify the languages, frameworks, runtimes, and package managers in use
- Determine whether the repo is a single project, polyrepo-like workspace, or monorepo
- Read the existing source-of-truth docs and config before writing anything

Check for signals such as:
- `README.md`, contributor docs, and setup docs
- `package.json`, lockfiles, workspace config, `Makefile`, `justfile`
- `pyproject.toml`, `uv.lock`, `requirements*.txt`, `Pipfile`, `poetry.lock`
- CI workflows, Docker files, compose files, and deployment config
- test, lint, formatter, and type-check config

### 2. Extract Actionable Commands
- Record the exact install, run, build, lint, test, type-check, and release commands that actually exist
- Prefer commands agents can run directly without interpretation
- If multiple workflows exist, explain when to use each one
- If a command differs by subproject, say so explicitly

Do **not** invent commands, tools, scripts, or conventions that are not present in the repo.

### 3. Cover the Active Stack, Not Just JavaScript

Many repositories are not JavaScript-only. Adapt the file to the actual stack.

For **Python** repositories, explicitly look for and document items such as:
- required Python version (for example Python `3.14+` when specified)
- environment creation (`python -m venv .venv`, `uv venv`, or project-specific setup)
- dependency installation via `pip`, `uv`, Poetry, or requirements files
- test commands such as `pytest`
- lint/type-check commands such as Ruff, mypy, pyright, or project-specific tools
- app startup commands, module entry points, and environment variable expectations

For **JavaScript/TypeScript** repositories, document:
- package manager choice (`npm`, `pnpm`, `yarn`, `bun`)
- workspace/package layout where relevant
- build/test/lint/type-check scripts from `package.json`
- dev server, watch mode, and framework-specific commands

For **mixed-stack** repositories, include both sets of instructions and make the boundaries clear.

### 4. Write the File for Agents
- Keep it concise, but include enough detail that an agent can act without guessing
- Favor exact commands in backticks
- Explain repository-specific gotchas, not generic programming advice
- Distinguish required steps from optional tips
- Use standard Markdown headings so the file is easy for humans and tools to parse

### 5. Validate Before Finalizing
- Confirm that every documented command or path exists
- Confirm that the file reflects the current repo layout
- If the repo lacks a build, lint, or test workflow, say that plainly instead of fabricating one
- If guidance is ambiguous, prefer a short note about the ambiguity over making assumptions

---

## Recommended Sections

Adapt the structure to the project, but usually include:

### Project Overview
- What the repository does
- High-level architecture or major components when helpful
- Primary languages, frameworks, and tooling

### Setup Commands
- Dependency installation
- Environment creation and activation
- Local configuration and environment variables
- Database or service bootstrap if applicable

### Development Workflow
- How to run the app locally
- Watch mode / hot reload / background services
- Common edit-test-debug loop guidance

### Testing Instructions
- How to run the full test suite
- How to run targeted tests
- Test locations and naming patterns if discoverable
- Coverage, fixtures, or integration prerequisites when relevant

### Code Style and Conventions
- Formatter, linter, and type-checker commands
- Naming or layout conventions that affect edits
- Import/module organization patterns that recur in the repo

### Build and Deployment
- Build commands and artifacts
- Packaging or release steps
- CI/CD or deployment references when they shape local work

### Security and Secrets
- Where secrets come from
- Files or directories agents must not modify casually
- Auth, permissions, or sensitive-data handling constraints

### PR / Contribution Workflow
- Required checks before commit or PR
- Commit or PR title conventions if documented
- Review expectations or generated-file rules

### Troubleshooting / Gotchas
- Common setup failures
- Platform-specific caveats
- Monorepo navigation tips when relevant

---

## Output Requirements

The resulting `AGENTS.md` should:
- be created at the repository root unless a subproject root is explicitly targeted
- complement `README.md` instead of duplicating it wholesale
- be specific to the repository
- contain concrete commands that an agent can execute
- clearly state missing or non-existent tooling where applicable
- mention nested `AGENTS.md` files only when they are genuinely needed

---

## Quality Bar

Before finishing, verify that the file is:
- **accurate**: derived from real files and commands
- **actionable**: includes exact commands, paths, and workflow hints
- **stack-aware**: supports Python, JavaScript, or mixed repos as appropriate
- **maintainable**: avoids unnecessary boilerplate and stale implementation detail
- **agent-focused**: optimized for coding agents, not general marketing copy

---

## Tone and Approach

- Be concrete and operational.
- Prefer project truth over generic templates.
- Do not assume a JavaScript-first workflow.
- Treat Python-first and mixed-language repositories as first-class cases.
- When in doubt, document what is verified and flag what still needs confirmation.
