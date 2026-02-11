{ pkgs, ... }:
{
  # ============================================================
  # フォント設定
  # ============================================================

  home.packages = with pkgs; [
    # Powerline フォント
    powerline-fonts

    # Nerd Fonts (Powerline 互換 + 追加アイコン)
    meslo-lgs-nf
    nerd-fonts.jetbrains-mono
  ];
}
