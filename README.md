# agentic-coding-skills

A collection of `SKILL.md` files for use with agentic coding systems (GitHub Copilot agent, Cursor, Claude Code, etc.). Each skill is a self-contained instruction file you can reference or paste into an AI conversation to give the model a specific, well-defined role.

Skills are designed to work across models — primarily Claude (Opus/Sonnet) and OpenAI (GPT) models.

---

## Available Skills

| Skill | Description |
|---|---|
| [adversarial-review](./adversarial-review/SKILL.md) | Have a fresh AI model conduct a skeptical, adversarial review of code changes produced by another AI. Designed for GPT models reviewing Claude-authored PRs. |

---

## Proposed Skills

The following skills are planned for future addition:

| Skill | Description |
|---|---|
| **architecture-planning** | Guide an AI through structured technical planning before any code is written — producing a clear spec, decision log, and implementation checklist for a Sonnet-class model to follow. |
| **security-audit** | A focused security-only review that checks for injection, auth gaps, secrets exposure, insecure dependencies, and other OWASP-class vulnerabilities. |
| **test-generation** | Drive an AI to generate comprehensive test suites — covering unit, integration, edge-case, and regression scenarios — rather than just happy-path tests. |
| **refactoring-guide** | Systematically improve code quality without changing behavior: remove duplication, improve naming, simplify logic, and modernize patterns. |
| **dependency-audit** | Review newly added or updated dependencies for known vulnerabilities, unnecessary scope, licence issues, and maintenance health. |
| **performance-review** | Profile and critique code for latency, throughput, and resource usage bottlenecks. Includes common AI failure modes like N+1 queries and unnecessary re-computation. |
| **documentation-writer** | Generate accurate, consistently styled documentation (README, API docs, inline comments) that matches the conventions of an existing codebase. |
| **onboarding-guide** | Analyse a codebase and produce a structured guide for new developers: architecture overview, key entry points, data flow, gotchas, and local setup instructions. |
| **migration-assistant** | Plan and execute database or API migrations safely — generating rollback strategies, compatibility shims, and step-by-step execution plans. |
| **incident-review** | Conduct a blameless post-mortem on a production incident: establish a timeline, identify contributing causes, and produce actionable follow-up items. |

---

## Usage

1. Open the `SKILL.md` file for the skill you want to use.
2. Paste its contents into the system prompt or as the first user message in a new conversation with your chosen AI model.
3. Provide the AI with the relevant context (PR diff, codebase description, issue text, etc.) as the next message.

Skills are intentionally standalone — no tooling or framework required.