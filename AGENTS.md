# Repository Guidelines

## Language Note
- Please communicate in Japanese for discussions and contributions.

## Project Structure & Module Organization
- Root holds the Nix flake entrypoint and docs: `flake.nix`, `README.md`, `Makefile`.
- macOS system configuration lives in `darwin/default.nix` and is wired by the flake output.
- There are no separate test or asset directories in this repo.

## Build, Test, and Development Commands
- `make help`: lists available targets and brief descriptions.
- `make init`: first-time nix-darwin bootstrap (moves existing `/etc` files if needed, then runs `darwin-rebuild`).
- `make apply`: applies the current nix-darwin configuration.
- `make build`: builds the nix-darwin system derivation without switching.

Notes: This repo assumes macOS; the Make targets exit on non-Darwin systems. The Makefile exports `NIXBLD_GID` and builds with `--impure` to match an existing Nix install.

## Coding Style & Naming Conventions
- Nix files follow standard `nixpkgs` formatting (2-space indentation, braces on their own lines).
- Keep module names and paths explicit: macOS config stays in `darwin/default.nix`.
- Prefer descriptive names in comments and section headers; the repo uses short, labeled sections.

## Testing Guidelines
- There are no automated tests in this repository.
- Validate changes by running `make build` (dry build) and `make apply` (switch) on macOS.

## Commit & Pull Request Guidelines
- Commit history is minimal; no strict convention is enforced. Use short, descriptive messages (e.g., “Add zsh package”).
- PRs should include: a concise summary, the exact `make` command(s) run, and any macOS-specific considerations.

## Configuration Tips
- This flake targets Apple Silicon (`aarch64-darwin`). Adjust `system` in `flake.nix` if supporting other architectures.
- System packages are declared in `environment.systemPackages` inside `darwin/default.nix`.
