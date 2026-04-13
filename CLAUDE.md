# Khushu — Claude Code Instructions

## Security: Secrets, API Keys, Passwords

**NEVER commit secrets, API keys, passwords, tokens, or credentials to this repo.**

- Before staging files, check for hardcoded secrets (API keys, tokens, passwords, connection strings)
- If you detect a secret about to be committed: **STOP, warn the user, and ask before proceeding**
- Use environment variables or local-only config files for secrets (e.g., `.claude/projects/.../settings.local.json`)
- The `.gitignore` already excludes `.env`, `*.pem`, `*.key`, `*.keystore`, `key.properties`, and credential files
- If a new secret-bearing file type is introduced, add it to `.gitignore` before committing

If the user pastes a secret in the conversation, warn them immediately and recommend rotating it.

## Git Workflow

**`main` is protected. Never push directly to main.**

- Create a feature branch for all work (e.g., `feat/hijri-calendar`, `fix/asr-cache`)
- Commit to the feature branch
- Submit a PR to merge into main
- Wait for user approval before merging
- **Never add `Co-Authored-By` lines to commit messages**

## Git Worktrees

This project uses git worktrees for parallel feature development. Worktrees live in `.worktrees/` (gitignored).

**Start a new feature branch in a worktree:**
```bash
git worktree add .worktrees/feat-X -b feat/X
```

**List active worktrees:**
```bash
git worktree list
```

**Remove a worktree after merging:**
```bash
git worktree remove .worktrees/feat-X
```

Each worktree is fully isolated — separate working directory, `build/`, and `.dart_tool/`. They share `~/.pub-cache` safely. Always run `fvm flutter pub get` inside a new worktree before building.

## Implementation Rules

- **Commit after each task group** — don't batch up large uncommitted changes
- **Mark tasks complete immediately** — update `- [ ]` to `- [x]` in the OpenSpec tasks.md as each task finishes
- **Push to branch frequently** — so progress survives context resets
- **Implement autonomously** — follow the OpenSpec tasks, write code, run tests, fix issues without asking
- **Never deploy to phone or Play Store without user permission** — build and test locally, but wait for the user before installing on device
