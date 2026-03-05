---
name: flake-update
description: "nix-darwin リポジトリで Homebrew と flake 入力を更新し、build 検証、手動 apply 待機、commit/push までを固定手順で実行する。依存更新や定期メンテナンスを依頼されたときに使う。"
---

# Flake Update

nix-dotfiles の更新作業を安全に進めるため、次の順序を厳守して実行する。

## 前提

- 作業ディレクトリは対象リポジトリのルートとする。
- 更新フローは `make flake-update-flow-pre` / `make flake-update-flow-post` を使う。
- `make apply` はユーザーが手動で実行する。代行しない。

## 実行手順

1. pre-apply フローを実行する。
```bash
make flake-update-flow-pre
```
このターゲットが `brew update/upgrade`、`make flake-update`、`git add flake.lock`、`make build` を順に実行する。

5. ユーザーに `make apply` 実行を依頼し、完了確認を待つ。
```text
ビルドが成功しました。以下のコマンドを実行してください:

make apply

完了したら教えてください。
```

6. post-apply フローを実行する。
```bash
make flake-update-flow-post
```
必要なら push をスキップする:
```bash
make flake-update-flow-post FLOW_ARGS="--no-push"
```

## 実行ルール

- 各フェーズの結果を明示しながら進捗報告する。
- いずれかのコマンドが失敗したら、エラー内容を報告して停止する。
- `make apply` 完了の明示的なユーザー確認前に commit/push へ進まない。

## 失敗時の扱い

- `make flake-update-flow-pre` 失敗: エラー報告して中断する。
- `make flake-update-flow-post` 失敗: エラー報告して中断する。
