# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Communication

**日本語で対話してください。** このリポジトリの作業では、ユーザーとのすべてのコミュニケーションを日本語で行ってください。

## Repository Overview

This is a **nix-darwin configuration** for macOS (Apple Silicon) that provides declarative system and user environment management using:

- **nix-darwin**: System-level macOS configuration
- **Home Manager**: User-level dotfiles and configurations
- **mise**: Development tool version management
- **Homebrew**: GUI application installation via Casks

For detailed technical documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Important Workflow Rules

### 1. Git-Tracked Files Only

**Nix flakes only see files tracked by git.** After modifying any files, you MUST stage them with `git add` before running `make build` or `make apply`. Unstaged changes will NOT be visible to Nix.

```bash
# Always do this before building:
git add <modified-files>
make build  # or make apply
```

### 2. Always Use Make Commands

The flake requires `DARWIN_USER`, `NIXBLD_GID`, and optionally `GIT_USER_NAME`/`GIT_USER_EMAIL` environment variables. The Makefile automatically exports these. **Never run `nix` commands directly—always use `make` commands.**

```bash
make build   # Build configuration
make apply   # Apply configuration (requires sudo)
make init    # Initial setup (first-time only)
```

### 3. Shell Reload After Changes

After applying configuration changes that affect shell files, restart tmux completely:

```bash
tmux kill-server
tmux
```

Simply opening a new tmux window (LEADER+c) does NOT reload the environment.

## Common Tasks

### Modifying Configuration

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed instructions on:
- Adding system packages
- Adding development tools (mise)
- Adding GUI applications (Homebrew Cask)
- Modifying shell configuration (zsh, oh-my-zsh)
- Modifying Git configuration
- Modifying tmux configuration
- Adding new dotfiles

### Basic Workflow

1. Edit configuration files
2. Stage changes: `git add <files>`
3. Build: `make build` (optional, for testing)
4. Apply: `make apply`
5. Restart shell/tmux if needed

## System-Specific Notes

- This configuration is for **Apple Silicon (aarch64) only**
- The Makefile auto-detects architecture and constructs the configuration name (`$USER-darwin`)
- All builds use `--impure` flag to read environment variables
