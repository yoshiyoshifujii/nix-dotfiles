{ config, pkgs, lib, ... }:
{
  # ============================================================
  # oh-my-zsh 設定
  # ============================================================

  # oh-my-zsh の設定は programs.zsh.oh-my-zsh で管理
  # ZSH_CUSTOM をダブルクォートで設定（Home Manager の custom オプションはシングルクォートで展開されないため）
  programs.zsh.initContent = lib.mkBefore ''
    ZSH_CUSTOM="$HOME/.oh-my-zsh-custom"
  '';

  programs.zsh.oh-my-zsh = {
    enable = true;
    theme = "powerlevel10k/powerlevel10k";
    plugins = [
      "aws"
      "docker"
      "docker-compose"
      "git"
      "github"
      "golang"
      "kubectl"
      "macos"
      "themes"
      "vi-mode"
      "fast-syntax-highlighting"
      "zsh-history-beginning-search"
    ];
  };

  # powerlevel10k と fast-syntax-highlighting をインストール
  home.packages = with pkgs; [
    zsh-powerlevel10k
    zsh-fast-syntax-highlighting
  ];

  # Environment variables
  programs.zsh.sessionVariables = {
    # oh-my-zsh のキャッシュディレクトリを XDG Base Directory に準拠
    ZSH_CACHE_DIR = "$HOME/.cache/oh-my-zsh";
  };

  # カスタムディレクトリの配置
  home.file = {
    # powerlevel10k テーマ
    ".oh-my-zsh-custom/themes/powerlevel10k".source =
      "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";

    # Nix パッケージのプラグイン
    ".oh-my-zsh-custom/plugins/fast-syntax-highlighting".source =
      "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";

    # ユーザー定義のカスタムプラグイン
    ".oh-my-zsh-custom/plugins/zsh-history-beginning-search" = {
      source = ./files/oh-my-zsh/custom/plugins/zsh-history-beginning-search;
      recursive = true;
    };
  };
}
