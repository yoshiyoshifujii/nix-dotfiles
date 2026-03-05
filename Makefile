# ============================================================
# Dotfiles Makefile
# ============================================================

.DEFAULT_GOAL := help

# .env ファイルから環境変数を読み込み（存在する場合）
-include .env
export

# ユーザー名 (環境変数が設定されていればそれを優先、なければ自動検出)
SYSTEM_USER ?= $(shell whoami)
export SYSTEM_USER

# システム検出
UNAME := $(shell uname)
ARCH := $(shell uname -m)

ifeq ($(UNAME),Darwin)
  ifeq ($(ARCH),arm64)
    DARWIN_CONFIG := $(SYSTEM_USER)-darwin
  else
    DARWIN_CONFIG := $(SYSTEM_USER)-darwin-x86
  endif
endif

# Nix コマンドのパス (sudo環境でも使えるようにフルパス指定)
NIX := /nix/var/nix/profiles/default/bin/nix

# Nix experimental features (flakes + nix-command)
NIX_EXPERIMENTAL_FEATURES ?= nix-command flakes
NIX_CONFIG ?= experimental-features = $(NIX_EXPERIMENTAL_FEATURES)
export NIX_CONFIG

# nixbld GID を自動検出 (nix-darwin との整合性用)
NIXBLD_GID := $(shell dscl . -read /Groups/nixbld PrimaryGroupID 2>/dev/null | awk '{print $$2}')
export NIXBLD_GID

MISE_DATA_DIR ?= $(HOME)/.local/share/mise
MISE_STATE_DIR ?= $(HOME)/.local/state/mise
MISE_CACHE_DIR ?= $(HOME)/Library/Caches/mise

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  help    Show this help"
	@echo "  init    Initial nix-darwin setup (macOS only)"
	@echo "  apply   Apply nix-darwin configuration"
	@echo "  build   Build nix-darwin configuration"
	@echo "  flake-update  Update all flake inputs"
	@echo "  flake-update-flow  Run pre-apply update flow (alias of flake-update-flow-pre)"
	@echo "  flake-update-flow-pre  Run brew/update/stage/build before manual apply"
	@echo "  flake-update-flow-post  Commit/push flake.lock after manual apply"
	@echo "  flake-update-nixpkgs  Update only nixpkgs input"
	@echo "  flake-lock-diff  Show flake.lock diff"
	@echo "  closure-diff  Compare current system and ./result closure"
	@echo "  clean   Remove local build artifacts"
	@echo "  mise-install  Install tools defined by mise config"
	@echo "  mise-purge    Remove mise installed tools and cache"

# ============================================================
# Build
# ============================================================

build:
ifeq ($(UNAME),Darwin)
	@echo "Building nix-darwin configuration: $(DARWIN_CONFIG)"
	$(NIX) build --impure .#darwinConfigurations.$(DARWIN_CONFIG).system
else
	@echo "nix-darwin is only available on macOS"
	@exit 1
endif

clean:
	@echo "Removing local build artifacts..."
	rm -f result

# ============================================================
# Flake Update
# ============================================================

flake-update:
	@echo "Updating all flake inputs..."
	$(NIX) flake update

flake-update-flow:
	$(MAKE) flake-update-flow-pre

flake-update-flow-pre:
	@echo "Running pre-apply flake update flow..."
	bash scripts/flake-update-flow.sh pre

flake-update-flow-post:
	@echo "Running post-apply flake update flow..."
	bash scripts/flake-update-flow.sh post $(FLOW_ARGS)

flake-update-nixpkgs:
	@echo "Updating flake input: nixpkgs"
	$(NIX) flake lock --update-input nixpkgs

flake-lock-diff:
	@echo "Showing flake.lock diff..."
	git diff -- flake.lock

closure-diff:
ifeq ($(UNAME),Darwin)
	@echo "Comparing closures: /run/current-system vs ./result"
	$(NIX) store diff-closures /run/current-system ./result
else
	@echo "closure-diff target is only available on macOS"
	@exit 1
endif

# ============================================================
# Apply
# ============================================================

apply-darwin:
ifeq ($(UNAME),Darwin)
	@echo "Applying nix-darwin configuration: $(DARWIN_CONFIG)"
	sudo -E $(NIX) run nix-darwin#darwin-rebuild -- switch --flake .#$(DARWIN_CONFIG) --impure
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
	sudo -E $(NIX) run nix-darwin#darwin-rebuild -- switch --flake .#$(DARWIN_CONFIG) --impure
else
	@echo "nix-darwin is only available on macOS"
	@exit 1
endif

init:
	$(MAKE) init-darwin

# ============================================================
# mise
# ============================================================

mise-install:
ifeq ($(UNAME),Darwin)
	@echo "Installing tools from mise config..."
	mise install
else
	@echo "mise targets are intended for macOS in this repository"
	@exit 1
endif

mise-purge:
ifeq ($(UNAME),Darwin)
	@echo "Purging mise data, state, and cache..."
	rm -rf "$(MISE_DATA_DIR)" "$(MISE_STATE_DIR)" "$(MISE_CACHE_DIR)"
else
	@echo "mise targets are intended for macOS in this repository"
	@exit 1
endif
