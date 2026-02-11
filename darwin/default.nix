{ config, pkgs, username, ... }:
{
  # ============================================================
  # nix-darwin システムレベル設定
  # macOS のシステム設定を Nix で宣言的に管理
  # ============================================================

  # Nix 設定
  nix = {
    settings = {
      # Flakes を有効化
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # nixbld グループの GID を既存環境に合わせる (Makefile から注入)
  ids.gids.nixbld =
    let
      gidStr = builtins.getEnv "NIXBLD_GID";
    in
    if gidStr == "" then 350 else builtins.fromJSON gidStr;

  # ============================================================
  # システムパッケージ
  # ============================================================
  environment.systemPackages = with pkgs; [
    git
    mise
    wezterm
    elan
  ];

  # ============================================================
  # システムユーザー
  # ============================================================
  system.primaryUser = username;

  # ============================================================
  # Homebrew (GUI アプリは Cask で管理)
  # ============================================================
  homebrew = {
    enable = true;
    casks = [
      "ghostty"
    ];
  };

  # ============================================================
  # シェル設定
  # ============================================================
  programs.zsh.enable = true;

  # ============================================================
  # ユーザー設定 (home-manager 連携のため)
  # ============================================================
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  system.stateVersion = 4;
}
