{ config, pkgs, lib, ... }:
{
  # ============================================================
  # Neovim 設定
  # LazyVim を ~/.config/nvim に配置（未作成時のみ clone）
  # ============================================================

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.activation.setupLazyVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NVIM_CONFIG_DIR="$HOME/.config/nvim"

    if [ -d "$NVIM_CONFIG_DIR/.git" ]; then
      echo "LazyVim repository already exists at $NVIM_CONFIG_DIR"
    elif [ -e "$NVIM_CONFIG_DIR" ]; then
      echo "Skip LazyVim setup: $NVIM_CONFIG_DIR exists but is not a git repository"
    else
      mkdir -p "$HOME/.config"
      ${pkgs.git}/bin/git clone https://github.com/yoshiyoshifujii/LazyVim "$NVIM_CONFIG_DIR"
    fi
  '';
}
