{ config, pkgs, username, nixbldGid, ... }:
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

  # nixbld グループの GID を既存環境に合わせる (flake.nix から注入)
  ids.gids.nixbld = nixbldGid;

  # ============================================================
  # システムパッケージ
  # ============================================================
  environment.systemPackages = with pkgs; [
    awscli2
    git
    gh
    mise
    uv
    neovim
    pkgs."terminal-notifier"
    fd
    ripgrep
    tmux
    wezterm
    elan
    kubectx
    k9s
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
      "claude-code"
      "1password"
      "1password-cli"
      "alfred"
      "bettertouchtool"
      "clipy"
      "docker-desktop"
      "ghostty"
      "jetbrains-toolbox"
      "karabiner-elements"
      "macskk"
      "miro"
    ];
  };

  # ============================================================
  # セキュリティ設定
  # ============================================================
  # sudo コマンドで Touch ID (指紋認証) を使えるようにする
  # reattach = true で tmux 内でも Touch ID が動作する
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
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
    shell = pkgs.zsh;
  };

  system.stateVersion = 4;
}
