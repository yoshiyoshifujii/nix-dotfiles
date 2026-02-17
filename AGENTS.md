# Repository Guidelines

## プロジェクト概要

macOS 向けの `nix-darwin` 設定リポジトリ。  
Flake ベースでシステム設定を管理し、変更は「最小差分・再現可能・安全」を優先する。

## ディレクトリ構造

- `flake.nix` - エントリポイント（flake outputs 定義）
- `darwin/` - macOS（nix-darwin）関連の設定
- `home/` - Home Manager 関連の設定
- `Makefile` - `nix-darwin` の補助コマンド
- `README.md` - セットアップと運用メモ

## 開発コマンド

- `make help` - 利用可能なターゲット一覧
- `make init` - 初回セットアップ
- `make build` - 切り替えなしビルド（事前確認）
- `make apply` - 設定を実機に反映

## 設計方針

- やり取りは日本語で行う。
- 大きな再設計より、意図が明確な小さな変更を優先する。
- 対象環境は macOS（非 Darwin では `make` ターゲットは失敗する前提）。
- パッケージ追加は `darwin/default.nix` の `environment.systemPackages` で管理する。
- Nix 記法は `nixpkgs` 標準（2スペースインデント）に合わせる。

## 詳細ドキュメント

- セットアップ/運用: `README.md`
