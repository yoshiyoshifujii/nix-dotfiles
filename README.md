# dotfiles

Minimal nix-darwin config for macOS (Apple Silicon only).

## Structure

```
.
├── flake.nix
├── darwin/
│   └── default.nix
├── Makefile
└── README.md
```

## Prerequisites

1. Xcode Command Line Tools

```bash
xcode-select --install
```

2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After install, add Homebrew to PATH:

```bash
# Apple Silicon Mac
eval "$(/opt/homebrew/bin/brew shellenv)"
```

3. Nix

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

Restart the shell:

```bash
exec $SHELL
```

## Usage

### Initial Setup

First time only:

```bash
make init
```

### Configure Git User (Optional)

Create a `.env` file from the template and set your git user information:

```bash
cp .env.example .env
# Edit .env and fill in your values
```

`.env` example:
```bash
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your@email.com
```

### Apply Configuration

```bash
make apply
```

You can also run the same operation from any directory after one successful apply:

```bash
darwinctl apply
```

After applying, restart your shell or tmux:

```bash
tmux kill-server
tmux
```

### Install Development Tools

Install tools defined in mise config:

```bash
make mise-install
```

Verify installation:

```bash
java -version
python --version
node --version
```

### Build Only (Dry Run)

To check for errors without applying:

```bash
make build
```

### Update Flake Inputs Safely

When updating `flake.lock`, review the diff and build impact before applying:

```bash
# 1) Update lock file
make flake-update

# 2) Review lock diff
make flake-lock-diff

# 3) Build new system closure
make build

# 4) Compare current system vs new build
make closure-diff

# 5) Apply if everything looks good
make apply
```

If you prefer a Homebrew-like entrypoint that works without `cd`, use `darwinctl`:

```bash
# pre-apply phase: sync + flake update + build
darwinctl update

# apply from anywhere
darwinctl apply

# inspect lock diff
darwinctl diff

# compare closures after build
darwinctl closure-diff

# post-apply phase: commit + push flake.lock
darwinctl post
```

Tip: To reduce update scope/noise, update only one input:

```bash
make flake-update-nixpkgs
```

You can also run the standard flow via make targets:

```bash
# pre-apply phase: sync + flake update + build
make flake-update-flow

# manual apply (run yourself)
make apply

# post-apply phase: commit + push flake.lock
make flake-update-flow-post

# post-apply phase: commit only (skip push)
make flake-update-flow-post FLOW_ARGS="--no-push"
```

## Security Check (pre-commit + gitleaks)

Install and enable:

```bash
nix shell nixpkgs#pre-commit -c pre-commit install
```

Run manually:

```bash
nix shell nixpkgs#pre-commit -c pre-commit run --all-files
```

Note: This setup reads `NIXBLD_GID` from the environment to align nix-darwin
with the existing Nix install. The Makefile auto-detects this and uses
`--impure` when building/applying.

## Make targets

```bash
make help
```

| Target | Description |
| --- | --- |
| `init` | Initial nix-darwin setup (macOS only) |
| `apply` | Apply nix-darwin configuration |
| `build` | Build nix-darwin configuration |
| `flake-update` | Update all flake inputs |
| `flake-update-flow` | Alias of `flake-update-flow-pre` |
| `flake-update-flow-pre` | Run sync + flake update + stage + build |
| `flake-update-flow-post` | Commit and push `flake.lock` after manual `make apply` |
| `flake-update-nixpkgs` | Update only the `nixpkgs` input |
| `flake-lock-diff` | Show `flake.lock` diff |
| `closure-diff` | Compare `/run/current-system` and `./result` |
| `clean` | Remove local build artifacts (`result`) |
| `mise-install` | Install tools defined in mise config |
| `mise-purge` | Remove mise installed tools and cache |

Global wrapper command installed by this config:

| Command | Description |
| --- | --- |
| `darwinctl update` | Run the standard pre-apply update flow from any directory |
| `darwinctl apply` | Apply nix-darwin configuration from any directory |
| `darwinctl diff` | Show `flake.lock` diff |
| `darwinctl closure-diff` | Compare `/run/current-system` and `./result` |
| `darwinctl post` | Run post-apply commit/push flow |
| `darwinctl make ...` | Forward arbitrary targets to the repo `Makefile` |

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)**: Detailed technical documentation, configuration structure, and how to modify settings
- **[CLAUDE.md](CLAUDE.md)**: Guidance for Claude Code when working with this repository
