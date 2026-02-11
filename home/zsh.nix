{ config, pkgs, lib, ... }:
{
  # ============================================================
  # Zsh 設定 (Home Manager)
  # ============================================================
  programs.zsh = {
    enable = true;

    # oh-my-zsh 設定
    oh-my-zsh = {
      enable = true;
      custom = "$HOME/.oh-my-zsh-custom";
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

    # Additional configuration
    initContent = lib.mkMerge [
      # Powerlevel10k instant prompt (must be at the top)
      (lib.mkBefore ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      # Additional configuration (after oh-my-zsh initialization)
      ''
        # mise activation
        eval "$(mise activate zsh)"

        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      ''
    ];

    # Environment variables
    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      # oh-my-zsh のキャッシュディレクトリを XDG Base Directory に準拠
      ZSH_CACHE_DIR = "$HOME/.cache/oh-my-zsh";
    };
  };

  # powerlevel10k と fast-syntax-highlighting をインストール
  home.packages = with pkgs; [
    zsh-powerlevel10k
    zsh-fast-syntax-highlighting
  ];

  home.file = {
    # custom ディレクトリを ~/.oh-my-zsh-custom に配置
    # powerlevel10k を custom/themes にリンク
    ".oh-my-zsh-custom/themes/powerlevel10k".source =
      "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";

    # fast-syntax-highlighting を custom/plugins にリンク
    ".oh-my-zsh-custom/plugins/fast-syntax-highlighting".source =
      "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
  };
}
