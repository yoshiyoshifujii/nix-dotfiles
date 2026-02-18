# Claude Code ガイドライン

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

## 作業ルール

### Git ステージングを忘れない

Nix flake はgit管理ファイルのみ参照する。変更後は必ず `git add` してからビルドする。

```bash
git add <変更ファイル>
make build  # または make apply
```

### `nix` コマンドを直接実行しない

Makefile が必要な環境変数（`DARWIN_USER`、`NIXBLD_GID` 等）を自動でセットする。
`nix` コマンドは直接使わず、必ず `make` コマンドを使う。

## 詳細ドキュメント

- アーキテクチャ/設定変更手順: `ARCHITECTURE.md`
- セットアップ/運用: `README.md`
