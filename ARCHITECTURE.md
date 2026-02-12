# Architecture

This document provides detailed technical information about the nix-darwin configuration structure and how to modify it.

## Overview

This is a **nix-darwin configuration** for macOS (Apple Silicon) that provides declarative system and user environment management. The configuration uses:

- **nix-darwin**: System-level macOS configuration
- **Home Manager**: User-level dotfiles and configurations
- **mise**: Development tool version management (Java, Python, Node.js, Rust, etc.)
- **Homebrew**: GUI application installation via Casks

## Configuration Flow

```
flake.nix (entry point)
├── darwin/default.nix (system-level: packages, Homebrew, system settings)
└── home/default.nix (user-level: dotfiles via Home Manager)
    ├── home/files/* (zshenv, zprofile, p10k.zsh, mise/config.toml, tmux.conf.local, custom oh-my-zsh plugins, wezterm configs)
    ├── home/fonts.nix (fonts: powerline-fonts, nerd-fonts)
    ├── home/git.nix (git configuration)
    ├── home/zsh.nix (zsh configuration)
    ├── home/oh-my-zsh.nix (oh-my-zsh, plugins, themes)
    ├── home/mise.nix (mise development tool version management)
    ├── home/tmux.nix (tmux configuration using gpakosz/.tmux)
    ├── home/ghostty.nix (ghostty terminal config)
    └── home/wezterm.nix (wezterm terminal config)
```

## Key Architectural Decisions

### 1. Environment Variables

The flake requires `DARWIN_USER` and `NIXBLD_GID` environment variables. The Makefile automatically exports these, which is why direct `nix` commands won't work—always use `make` commands.

Git user configuration also uses environment variables (`GIT_USER_NAME`, `GIT_USER_EMAIL`) for flexibility across different environments.

### 2. Impure Builds

All builds use `--impure` flag because they read environment variables to align with existing system configuration.

### 3. Tool Management Split

- **System packages** (git, mise, tmux, wezterm): Managed by nix-darwin in `darwin/default.nix`
- **GUI applications** (ghostty): Managed by Homebrew Cask in `darwin/default.nix`
- **Development tools** (Java, Python, Node, Rust, Maven, Gradle, etc.): Managed by mise via `home/files/mise/config.toml`

### 4. Shell Configuration

- **zsh and oh-my-zsh**: Managed declaratively via Home Manager's `programs.zsh` module in `home/zsh.nix`
- **zshenv and zprofile**: Managed as plain files in `home/files/` for environment variable setup
- **oh-my-zsh custom plugins**: User-defined plugins in `home/files/oh-my-zsh/custom/plugins/` are symlinked to `~/.oh-my-zsh-custom/plugins/`
- This hybrid approach allows declarative management of core configuration while maintaining flexibility for custom plugins

### 5. Backup Strategy

`backupFileExtension = "backup"` in `home/default.nix` ensures existing dotfiles are backed up with a `.backup` extension when Home Manager takes over management.

## Modifying Configuration

**IMPORTANT**: After modifying any files, you MUST stage them with `git add` before running `make build` or `make apply`. Nix flakes only see git-tracked files.

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

Then:
```bash
git add darwin/default.nix
make apply
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

Then:
```bash
git add home/files/mise/config.toml
make apply
make mise-install
```

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

Then:
```bash
git add darwin/default.nix
make apply
```

### Modifying Shell Configuration

#### Zsh basic configuration

1. Edit `home/zsh.nix` to modify zsh settings (mise, editor, etc.)
2. Stage changes: `git add home/zsh.nix`
3. Apply: `make apply`
4. Restart shell/tmux

#### oh-my-zsh configuration (plugins, theme)

1. Edit `home/oh-my-zsh.nix` to modify oh-my-zsh settings
2. Stage changes: `git add home/oh-my-zsh.nix`
3. Apply: `make apply`
4. Restart shell/tmux

#### Environment variables (zshenv, zprofile)

1. Edit files in `home/files/` (zshenv, zprofile)
2. Stage changes: `git add home/files/filename`
3. Apply: `make apply`
4. Restart shell/tmux

#### Powerlevel10k theme customization

1. Run `p10k configure` to generate new configuration
2. Copy to repository: `cp ~/.p10k.zsh home/files/p10k.zsh`
3. Stage and apply: `git add home/files/p10k.zsh && make apply`

#### mise tool versions

1. Edit `home/files/mise/config.toml` to add/update tool versions
2. Stage and apply: `git add home/files/mise/config.toml && make apply`
3. Install tools: `make mise-install`

### Modifying Git Configuration

**Git basic configuration** (core.editor, color.ui) is managed declaratively in `home/git.nix`. User-specific settings (user.name, user.email) are configured via environment variables.

**Set Git user configuration**:

Option 1: Set environment variables before apply
```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your@email.com"
make apply
```

Option 2: Pass as command-line arguments
```bash
make apply GIT_USER_NAME="Your Name" GIT_USER_EMAIL="your@email.com"
```

Option 3: Edit Makefile to set default values
```makefile
# In Makefile:
GIT_USER_NAME ?= Your Name
GIT_USER_EMAIL ?= your@email.com
```

Then run `make apply`.

**Note**: If environment variables are not set, git user.name and user.email will not be configured (existing settings will be preserved).

### Modifying tmux Configuration

**tmux configuration** is managed using [gpakosz/.tmux](https://github.com/gpakosz/.tmux):

1. **Update base configuration** (gpakosz/.tmux version):
   - Edit `home/tmux.nix` to update `rev` and `sha256`
   - Use `nix-shell -p nix-prefetch-github --run 'nix-prefetch-github gpakosz .tmux'` to get the latest hash
   - Stage and apply: `git add home/tmux.nix && make apply`

2. **Customize settings** (prefix key, key bindings, theme):
   - Edit `home/files/tmux.conf.local` for customizations
   - **NEVER edit** `.tmux.conf` directly (managed by gpakosz/.tmux)
   - Stage and apply: `git add home/files/tmux.conf.local && make apply`
   - Restart tmux: `tmux kill-server && tmux`

3. **Key bindings in current config**:
   - Prefix key: `Ctrl-t` (customized from default `Ctrl-b`)
   - Split horizontal: `Ctrl-t` → `|`
   - Next window: `Ctrl-t` → `n` or `Space`
   - Previous window: `Ctrl-t` → `Backspace`
   - Copy mode: `Ctrl-t` → `[` (Vi mode enabled)

### Adding New Dotfiles

1. Create the file in `home/files/`
2. Add to `home/default.nix`:

```nix
home.file = {
  ".newfile".source = ./files/newfile;
};

# For XDG config files:
xdg.configFile = {
  "appname/config.toml".source = ./files/appname/config.toml;
};
```

3. Stage with `git add`, then `make apply`

## Important Notes

### Git-Tracked Files Only

Nix flakes only see files tracked by git. Always run `git add` for new or modified files before building. Unstaged changes will NOT be visible to Nix.

### Shell Reload

After applying configuration changes that affect shell files, restart tmux completely:

```bash
tmux kill-server
tmux
```

Simply opening a new tmux window (LEADER+c) does NOT reload the environment.

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
