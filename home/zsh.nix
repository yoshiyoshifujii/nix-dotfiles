{ config, pkgs, ... }:
{
  # ============================================================
  # Zsh 設定 (Home Manager)
  # ============================================================
  # .zshrc は home/files/zshrc で手動管理するため、
  # programs.zsh.oh-my-zsh は使用しない
  # （CLAUDE.md の方針: Shell files are managed as plain files）

  # powerlevel10k と fast-syntax-highlighting をインストール
  home.packages = with pkgs; [
    zsh-powerlevel10k
    zsh-fast-syntax-highlighting
  ];

  home.file = {
    # oh-my-zsh 本体を Nix で管理
    ".oh-my-zsh" = {
      source = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
      recursive = true;
    };

    # powerlevel10k を oh-my-zsh の custom/themes にリンク
    ".oh-my-zsh/custom/themes/powerlevel10k".source =
      "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";

    # fast-syntax-highlighting を oh-my-zsh の custom/plugins にリンク
    ".oh-my-zsh/custom/plugins/fast-syntax-highlighting".source =
      "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
  };
}
