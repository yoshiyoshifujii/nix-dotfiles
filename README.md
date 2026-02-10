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

Initial setup (first time only):

```bash
make init
```

Apply the configuration:

```bash
make apply
```

適用後は新しいシェルセッションを開いて、次を実行してください:

```bash
make mise/install
java -version
```

Build only:

```bash
make build
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
| `clean` | Remove local build artifacts (`result`) |
| `mise/install` | Install tools defined in mise config |
| `mise/purge` | Remove mise installed tools and cache |
