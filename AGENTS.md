# AGENTS.md

Guidance for AI code agents working in this repository.

## What This Repo Is

A curated library of reusable AI agent skills, Claude commands, and Pi prompts. The goal is to give code agents role-specific instruction sets that install into any supported project with a single script. Skills are platform-agnostic: the same Markdown files work across Claude Code, GitHub Copilot, OpenAI Codex, and OpenCode.

## Repository Structure

```
skills/                  # One subdirectory per skill, each containing a SKILL.md
  <skill-name>/
    SKILL.md
claude-commands/         # Claude Code slash commands (one .md file per command)
pi-prompts/              # Reserved for Pi prompt files (currently empty)
install.sh               # Interactive installer; the sole distribution mechanism
README.md                # Human-readable index of all skills and commands
```

## Skills

### Conventions

- Directory name: lowercase, hyphenated (e.g. `adversarial-review`, `test-generation`)
- File: always named exactly `SKILL.md`
- One skill per directory; no auxiliary files alongside `SKILL.md`

### Required SKILL.md Structure

Every skill must follow this section order:

```markdown
# [Skill Name]

## Overview
(3–5 sentences defining the agent role and objective)

## How to Use This Skill
(What inputs the agent expects; when to invoke this skill)

## [Main Process Section]
(Numbered subsections covering the workflow)

## Output Format
(The exact structure the agent should produce)

## Tone and Approach
(Behavioral guidance: directness, skepticism, etc.)
```

### Design Principles

- **Role-specific**: each skill defines one coherent agent role — do not blend concerns
- **Platform-transparent**: no tool-specific API calls or product names inside `SKILL.md`
- **Workflow-aware**: assume the agent has access to real diffs, files, and CI output — not summaries
- **OpenSpec-aware**: skills that involve reviewing changes (e.g. `adversarial-review`, `code-review`) should acknowledge OpenSpec artifact structures where relevant

## Claude Commands

- Stored in `claude-commands/` as plain `.md` files
- Installed to `.claude/commands/<name>.md`
- Invoked in Claude Code with `/<name>`
- Commands may reference platform-specific behaviors (Claude-only features are acceptable here)

## Platform Targets

The installer supports four platforms, each with its own discovery path:

| Platform | Discovery path (project-local) |
|----------|-------------------------------|
| `claude` | `.claude/skills/<skill>/SKILL.md` |
| `copilot` | `.github/skills/<skill>/SKILL.md` |
| `codex` | `.codex/skills/<skill>/SKILL.md` |
| `opencode` | `.agents/skills/<skill>/SKILL.md` |

OpenCode also scans `.claude/skills/`, so Claude-installed skills are auto-discovered there.

## The Installer (`install.sh`)

### Goals and Constraints

- Must run on **macOS (bash 3.2)** and **Linux (bash 4+)** without modification
- Do **not** use bash 4+ features: no `local -n` (nameref), no associative arrays (`declare -A`), no `readarray`/`mapfile`
- Use `eval`-based indirect array access where nameref would otherwise be needed
- The script uses `set -euo pipefail`; handle empty arrays carefully to avoid `set -u` failures

### Key Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `AGENTIC_SKILLS_REF` | `main` | Git ref to download from |
| `AGENTIC_SKILLS_BASE_URL` | GitHub raw URL | Override download base |
| `AGENTIC_SKILLS_SOURCE_DIR` | `skills` | Source directory name |
| `PROMPT_INPUT` / `PROMPT_OUTPUT` | `/dev/tty` | Interactive prompt I/O |

### Hardcoded Lists

`install.sh` maintains three bash arrays that must be kept in sync with the filesystem:

- `SKILLS` — one entry per subdirectory in `skills/`
- `CLAUDE_COMMANDS` — one entry per file in `claude-commands/`
- `PI_PROMPTS` — currently empty

When adding or removing a skill or command, update the corresponding array in `install.sh` **and** the table in `README.md`.

### Platform Auto-Detection

The script detects active platforms by checking for marker directories in the current working directory:

| Directory | Platform detected |
|-----------|------------------|
| `.claude` | `claude` |
| `.github` | `copilot` |
| `.codex` | `codex` |
| `.opencode` | `opencode` |

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` following the structure above
2. Add `<skill-name>` to the `SKILLS` array in `install.sh`
3. Add a row to the skills table in `README.md`

## Adding a New Claude Command

1. Create `claude-commands/<name>.md`
2. Add `<name>` to the `CLAUDE_COMMANDS` array in `install.sh`
3. Add a row to the commands table in `README.md`

## Testing

There is no automated test suite. Validation is through real-world use: install a skill into a project and run it against actual code. When changing `install.sh`, test interactively on both macOS (bash 3.2) and Linux (bash 4+) if possible. At minimum, run `bash -n install.sh` to check syntax.

## No Build Step

This repo contains only Markdown and shell script. There is nothing to compile, bundle, or package. Skills are distributed by downloading individual files directly from GitHub raw content URLs.
