{ config, pkgs, ... }:
let
  # gpakosz/.tmux を GitHub から取得
  # https://github.com/gpakosz/.tmux
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
  #
  # gpakosz/.tmux の特徴:
  # - Powerline 風のテーマ
  # - バッテリー・稼働時間などのステータス表示
  # - クリップボード統合 (macOS: pbcopy/pbpaste)
  # - マウスモード切り替え
  # - SSH/Mosh セッション情報表示
  #
  # 必要な依存関係:
  # - tmux >= 2.6 (darwin/default.nix で管理)
  # - awk, perl, grep, sed (macOS 標準)
  # - EDITOR/VISUAL 環境変数 (home/zsh.nix で設定済み)
  #
  # カスタマイズ方法:
  # - メイン設定ファイル (.tmux.conf) は編集しない
  # - カスタマイズは .tmux.conf.local で行う
  # - home/files/tmux.conf.local を編集
  # - git add → make apply で反映
  # ============================================================

  home.file = {
    # gpakosz/.tmux の .tmux.conf をシンボリックリンク
    ".tmux.conf".source = "${gpakoszTmux}/.tmux.conf";

    # カスタム設定 .tmux.conf.local を動的に生成
    # gpakosz のデフォルト設定 + カスタマイズを結合
    ".tmux.conf.local".text = ''
      ${builtins.readFile "${gpakoszTmux}/.tmux.conf.local"}

      # ============================================================
      # User customizations (added by Nix)
      # ============================================================

      # force Vi mode
      set -g status-keys vi
      set -g mode-keys vi

      # Custom prefix key: Ctrl-t
      set -gu prefix2
      unbind C-a
      unbind C-b
      set -g prefix ^T
      bind t send-prefix

      # next window: ^@ ^N sp n
      unbind ^@
      bind ^@ next-window
      unbind ^N
      bind ^N next-window
      unbind " "
      bind " " next-window
      unbind n
      bind n next-window

      # split window (vertical): |
      unbind |
      bind | split-window

      # previous window: Backspace
      unbind BSpace
      bind BSpace previous-window
    '';
  };

  # オプション: 追加ツール
  # 必要に応じてコメント解除してください
  # home.packages = with pkgs; [
  #   fpp         # PathPicker - ファイル選択ツール
  #   urlscan     # URL 抽出・選択ツール
  #   # urlview   # URL 抽出・選択ツール (代替)
  # ];
}
