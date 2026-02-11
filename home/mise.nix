{ config, pkgs, ... }:
{
  # ============================================================
  # mise 設定
  # 開発ツールのバージョン管理（Java, Python, Node.js, Rust など）
  # ============================================================

  # mise の設定ファイル
  xdg.configFile = {
    "mise/config.toml".source = ./files/mise/config.toml;
  };

  # mise activation を zsh に統合
  programs.zsh.initContent = ''
    # mise activation
    eval "$(mise activate zsh)"
  '';
}
