# ============================================================
# Dotfiles Makefile
# ============================================================

.DEFAULT_GOAL := help

# ユーザー名 (現在のログインユーザーを自動検出)
USER := $(shell whoami)

# システム検出
UNAME := $(shell uname)
ARCH := $(shell uname -m)

ifeq ($(UNAME),Darwin)
  ifeq ($(ARCH),arm64)
    DARWIN_CONFIG := $(USER)-darwin
  else
    DARWIN_CONFIG := $(USER)-darwin-x86
  endif
endif

# Nix experimental features (flakes + nix-command)
NIX_EXPERIMENTAL_FEATURES ?= nix-command flakes
NIX_CONFIG ?= experimental-features = $(NIX_EXPERIMENTAL_FEATURES)
export NIX_CONFIG

# nixbld GID を自動検出 (nix-darwin との整合性用)
NIXBLD_GID := $(shell dscl . -read /Groups/nixbld PrimaryGroupID 2>/dev/null | awk '{print $$2}')
export NIXBLD_GID

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  help    Show this help"
	@echo "  init    Initial nix-darwin setup (macOS only)"
	@echo "  apply   Apply nix-darwin configuration"
	@echo "  build   Build nix-darwin configuration"

# ============================================================
# Build
# ============================================================

build:
ifeq ($(UNAME),Darwin)
	@echo "Building nix-darwin configuration: $(DARWIN_CONFIG)"
	nix build --impure .#darwinConfigurations.$(DARWIN_CONFIG).system
else
	@echo "nix-darwin is only available on macOS"
	@exit 1
endif

# ============================================================
# Apply
# ============================================================

apply-darwin:
ifeq ($(UNAME),Darwin)
	@echo "Applying nix-darwin configuration: $(DARWIN_CONFIG)"
	sudo -E nix run nix-darwin#darwin-rebuild -- switch --flake .#$(DARWIN_CONFIG) --impure
else
	@echo "nix-darwin is only available on macOS"
	@exit 1
endif

apply:
	$(MAKE) apply-darwin

init-darwin:
ifeq ($(UNAME),Darwin)
	@echo "Preparing for first nix-darwin installation..."
	@# バックアップが存在しない場合のみ退避（再実行時に上書きしない）
	@[ -f /etc/nix/nix.conf.before-nix-darwin ] || sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin 2>/dev/null || true
	@[ -f /etc/bashrc.before-nix-darwin ] || sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin 2>/dev/null || true
	@[ -f /etc/zshrc.before-nix-darwin ] || sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin 2>/dev/null || true
	@echo "Running initial nix-darwin switch..."
	sudo -E nix run nix-darwin#darwin-rebuild -- switch --flake .#$(DARWIN_CONFIG) --impure
else
	@echo "nix-darwin is only available on macOS"
	@exit 1
endif

init:
	$(MAKE) init-darwin
