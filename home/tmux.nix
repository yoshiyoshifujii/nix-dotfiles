{ config, pkgs, ... }:
let
  # gpakosz/.tmux を GitHub から取得
  gpakoszTmux = pkgs.fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    rev = "87dcd13a28aeb5f18baee630e24b3f5765ae3a4f";
    sha256 = "sha256-rfJkL4EMMunbC7wGiw7O/1E/0XTzA2N+RR7gXEoalAY=";
  };
in
{
  # ============================================================
  # tmux 設定
  # ansible と同じ構成で gpakosz/.tmux を使用
  # ============================================================

  home.file = {
    # gpakosz/.tmux の .tmux.conf をシンボリックリンク
    ".tmux.conf".source = "${gpakoszTmux}/.tmux.conf";
    # カスタム設定 .tmux.conf.local をシンボリックリンク
    ".tmux.conf.local".source = ./files/tmux.conf.local;
  };
}
