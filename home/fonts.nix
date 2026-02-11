{ pkgs, ... }:
{
  # ============================================================
  # フォント設定
  # ============================================================

  home.packages = with pkgs; [
    # Powerline フォント
    # ansible の powerline/fonts リポジトリと同等
    powerline-fonts

    # Nerd Fonts (Powerline 互換 + 追加アイコン)
    meslo-lgs-nf
    nerd-fonts.jetbrains-mono
  ];
}
