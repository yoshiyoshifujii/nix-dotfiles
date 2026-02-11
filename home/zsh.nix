{ config, pkgs, lib, ... }:
{
  # ============================================================
  # Zsh 設定 (Home Manager)
  # ============================================================
  programs.zsh = {
    enable = true;

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

        # To customize prompt, run `p10k configure` or edit home/files/p10k.zsh
        source ~/.p10k.zsh
      ''
    ];

    # Environment variables
    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
