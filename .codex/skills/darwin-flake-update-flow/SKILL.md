---
name: darwin-flake-update-flow
description: "Run the standard nix-darwin flake maintenance workflow with command-first execution and safe dirty-worktree recovery. Use when the user asks to update flake inputs, build, wait for manual apply, and optionally commit/push, especially when execution is blocked by a dirty git state."
---

# Darwin Flake Update Flow

Prefer the repository command wrapper first, then use manual fallback only if needed.

## Standard Command Path

1. Check working tree status with `git status --short`.
2. If clean, run `make flake-update-flow`.
3. If commit is requested, run `make flake-update-flow FLOW_ARGS="--commit"`.
4. If push is requested, run `make flake-update-flow FLOW_ARGS="--push"`.

## Dirty Recovery Path

When the command path fails because the repository is dirty, recover safely before retrying.

1. Classify dirty files from `git status --short`:
- `??` only: untracked files only.
- `M`/`A`/`D` present: tracked changes exist.

2. For `??` only:
- Ask for confirmation, then run `git stash push -u -m "pre-flake-update-flow"`.
- Retry `make flake-update-flow` (or with `FLOW_ARGS`).
- After completion, run `git stash pop` and report conflicts if any.

3. For tracked changes:
- Do not auto-discard changes.
- Ask whether to:
- Create a separate commit first, then run the flow.
- Or stash all changes (`git stash push -u`) and restore after the flow.
- Proceed only after explicit user confirmation.

## Manual Fallback Path

Use only when command wrapper is unavailable or repeatedly fails.

1. Synchronize `main` with remote (`git fetch origin` and `git pull --ff-only origin main`).
2. Run `make flake-update`.
3. Run `make build`.
4. Ask the user to run `make apply` manually and wait for completion.
5. Commit `flake.lock` and push only when requested.

## Execution Rules

- Keep changes minimal and focused on `flake.lock` update results.
- Use non-interactive git commands only.
- Do not run `make apply` on behalf of the user.
- Never discard user changes without explicit instruction.
- If any command fails, report the error and stop before commit/push.
