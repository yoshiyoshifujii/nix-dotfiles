---
name: darwin-flake-update-flow
description: "Update a nix-darwin flake repository with a fixed safe workflow. Use when the user asks to run the standard maintenance flow of: sync main branch, run `make flake-update`, run `make build`, ask the user to run `make apply` manually and wait, then commit and push."
---

# Darwin Flake Update Flow

Execute the repository update flow in a strict order to keep changes reproducible and low risk.

## Workflow

1. Synchronize `main` with remote.
- Run non-interactive commands to move to the latest `origin/main` state.
- If the workspace has unexpected changes that block safe sync, stop and ask the user.

2. Run `make flake-update`.
- Execute from the repository root.

3. Run `make build`.
- Confirm the build succeeds before continuing.

4. Pause for manual `make apply`.
- Tell the user to run `make apply` themselves.
- Wait for explicit confirmation before continuing.

5. Commit and push.
- Inspect changed files.
- Commit only relevant updates from this flow.
- Push to remote branch.

## Execution Rules

- Keep changes minimal and focused on flake update results.
- Use non-interactive git commands only.
- Do not run `make apply` on behalf of the user.
- If any command fails, report the error and stop before commit/push.
