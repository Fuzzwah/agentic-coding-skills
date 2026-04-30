# Claude Commands

Place Claude command files in this directory.

Current commands:

- [`shipit`](./shipit.md): finalize the current branch with OpenSpec-aware checks before commit, PR, and merge confirmation.

Copy these files into `.claude/commands/` in a repository (or `~/.claude/commands/` for a personal install).

Keeping Claude-specific command artifacts separate from `skills/` avoids mixing different discovery and installation conventions in the same tree.
