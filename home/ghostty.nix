{ ... }:
{
  xdg.configFile."ghostty/config".text = ''
    # WezTerm と同じフォント/テーマ
    font-family = "MesloLGS NF"
    font-family = "JetBrainsMono Nerd Font"
    font-family = "JetBrains Mono"
    font-family = "Hiragino Sans"
    font-family = "YuGothic"
    font-family = "BIZ UDGothic"
    font-family = "Symbols Nerd Font Mono"
    font-size = 13.0
    theme = "Adventure"

    # 透過
    background-opacity = 0.8

    # パディング（WezTerm の 1cell 相当を近似）
    window-padding-x = 10
    window-padding-y = 10
  '';
}
