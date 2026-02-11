# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Communication

**日本語で対話してください。** このリポジトリの作業では、ユーザーとのすべてのコミュニケーションを日本語で行ってください。

## Overview

This is a **nix-darwin configuration** for macOS (Apple Silicon) that provides declarative system and user environment management. The configuration uses:

- **nix-darwin**: System-level macOS configuration
- **Home Manager**: User-level dotfiles and configurations
- **mise**: Development tool version management (Java, Python, Node.js, Rust, etc.)
- **Homebrew**: GUI application installation via Casks

## Common Commands

### Building and Applying Configuration

```bash
# Build the configuration (dry-run to check for errors)
make build

# Apply the configuration (requires sudo)
make apply

# Initial setup (first-time only)
make init
```

**IMPORTANT**: After modifying any files, you MUST stage them with `git add` before running `make build` or `make apply`. Nix flakes only see git-tracked files.

### Managing Development Tools

```bash
# Install all tools defined in mise config
make mise-install

# Remove all mise installed tools and cache
make mise-purge
```

After applying configuration changes that affect shell files, restart tmux completely:

```bash
tmux kill-server
tmux
```

Simply opening a new tmux window (LEADER+c) does NOT reload the environment.

## Architecture

### Configuration Flow

```
flake.nix (entry point)
├── darwin/default.nix (system-level: packages, Homebrew, system settings)
└── home/default.nix (user-level: dotfiles via Home Manager)
    ├── home/files/* (zshenv, zprofile, p10k.zsh, mise/config.toml, custom oh-my-zsh plugins)
    ├── home/zsh.nix (zsh configuration)
    ├── home/oh-my-zsh.nix (oh-my-zsh, plugins, themes)
    ├── home/mise.nix (mise development tool version management)
    ├── home/ghostty.nix (ghostty terminal config)
    └── home/wezterm.nix (wezterm terminal config)
```

### Key Architectural Decisions

1. **Environment Variables**: The flake requires `DARWIN_USER` and `NIXBLD_GID` environment variables. The Makefile automatically exports these, which is why direct `nix` commands won't work—always use `make` commands.

2. **Impure Builds**: All builds use `--impure` flag because they read environment variables to align with existing system configuration.

3. **Tool Management Split**:
   - **System packages** (git, mise, wezterm): Managed by nix-darwin in `darwin/default.nix`
   - **GUI applications** (ghostty): Managed by Homebrew Cask in `darwin/default.nix`
   - **Development tools** (Java, Python, Node, Rust, Maven, Gradle, etc.): Managed by mise via `home/files/mise/config.toml`

4. **Shell Configuration**:
   - **zsh and oh-my-zsh**: Managed declaratively via Home Manager's `programs.zsh` module in `home/zsh.nix`
   - **zshenv and zprofile**: Managed as plain files in `home/files/` for environment variable setup
   - **oh-my-zsh custom plugins**: User-defined plugins in `home/files/oh-my-zsh/custom/plugins/` are symlinked to `~/.oh-my-zsh-custom/plugins/`
   - This hybrid approach allows declarative management of core configuration while maintaining flexibility for custom plugins

5. **Backup Strategy**: `backupFileExtension = "backup"` in `home/default.nix` ensures existing dotfiles are backed up with a `.backup` extension when Home Manager takes over management.

## Modifying Configuration

### Adding System Packages

Edit `darwin/default.nix`:

```nix
environment.systemPackages = with pkgs; [
  git
  mise
  wezterm
  # Add new package here
];
```

### Adding Development Tools

Edit `home/files/mise/config.toml`:

```toml
[tools]
java = "temurin-21"
python = "latest"
node = "latest"
# Add new tool here
```

After applying configuration, run `make mise-install` to install the tools.

### Adding GUI Applications

Edit `darwin/default.nix`:

```nix
homebrew = {
  enable = true;
  casks = [
    "ghostty"
    # Add new cask here
  ];
};
```

### Modifying Shell Configuration

**Zsh basic configuration**:
1. Edit `home/zsh.nix` to modify zsh settings (mise, editor, etc.)
2. Stage changes: `git add home/zsh.nix`
3. Apply: `make apply`
4. Restart shell/tmux

**oh-my-zsh configuration (plugins, theme)**:
1. Edit `home/oh-my-zsh.nix` to modify oh-my-zsh settings
2. Stage changes: `git add home/oh-my-zsh.nix`
3. Apply: `make apply`
4. Restart shell/tmux

**Environment variables (zshenv, zprofile)**:
1. Edit files in `home/files/` (zshenv, zprofile)
2. Stage changes: `git add home/files/filename`
3. Apply: `make apply`
4. Restart shell/tmux

**Powerlevel10k theme customization**:
1. Run `p10k configure` to generate new configuration
2. Copy to repository: `cp ~/.p10k.zsh home/files/p10k.zsh`
3. Stage and apply: `git add home/files/p10k.zsh && make apply`

**mise tool versions**:
1. Edit `home/files/mise/config.toml` to add/update tool versions
2. Stage and apply: `git add home/files/mise/config.toml && make apply`
3. Install tools: `make mise-install`

### Adding New Dotfiles

1. Create the file in `home/files/`
2. Add to `home/default.nix`:

```nix
home.file = {
  ".newfile".source = ./files/newfile;
  # For XDG config files:
};

xdg.configFile = {
  "appname/config.toml".source = ./files/appname/config.toml;
};
```

3. Stage with `git add`, then `make apply`

## Important Notes

### Git-Tracked Files Only

Nix flakes only see files tracked by git. Always run `git add` for new or modified files before building. Unstaged changes will NOT be visible to Nix.

### Path Management

The configuration has migrated away from pyenv, nvm, and asdf to mise for unified version management. The PATH should no longer contain paths from these legacy tools. If old tool paths appear in PATH, check:

1. `.zprofile` - should only have Homebrew, Toolbox, and elan
2. `.zshrc` - should NOT have asdf, nvm, or pyenv plugins
3. `.zshenv` - should conditionally load cargo if it exists

### Security Checks

Pre-commit hooks with gitleaks can be installed:

```bash
nix shell nixpkgs#pre-commit -c pre-commit install
```

### System-Specific Configuration

This configuration is for **Apple Silicon (aarch64) only**. The Makefile auto-detects the architecture and constructs the appropriate configuration name (`$USER-darwin`).
