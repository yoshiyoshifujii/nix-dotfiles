{ config, pkgs, lib, ... }:
{
  # ============================================================
  # Zsh 設定 (Home Manager)
  # ============================================================
  programs.zsh = {
    enable = true;

    # .zshenv に追加する内容
    envExtra = ''
      # PATH settings
      if [ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]; then
        export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"
      fi

      # Load local zshenv if it exists
      if [ -f "$HOME/.zshenv.local" ]; then
        source "$HOME/.zshenv.local"
      fi
    '';

    # Additional configuration
    initContent = lib.mkMerge [
      # ユーザーローカルの補完ディレクトリを fpath に追加（p10k instant prompt より前に必要）
      (lib.mkBefore ''
        # User-local completions directory
        fpath=(~/.zsh/completions $fpath)
      '')

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
        # To customize prompt, run `p10k configure` or edit home/files/p10k.zsh
        source ~/.p10k.zsh
      ''
    ];

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
