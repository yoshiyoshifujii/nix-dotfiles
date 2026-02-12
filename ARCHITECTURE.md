# アーキテクチャ

このドキュメントでは、nix-darwin 設定の構造と変更方法について、技術的な詳細を説明します。

## 概要

これは macOS（Apple Silicon）向けの **nix-darwin 設定**であり、宣言的なシステム環境・ユーザー環境管理を提供します。構成要素は次のとおりです。

- **nix-darwin**: システムレベルの macOS 設定
- **Home Manager**: ユーザーレベルの dotfiles・設定管理
- **mise**: 開発ツールのバージョン管理（Java、Python、Node.js、Rust など）
- **Homebrew**: Cask 経由での GUI アプリインストール

## 設定フロー

```
flake.nix (エントリーポイント)
├── darwin/default.nix (システムレベル: パッケージ、Homebrew、システム設定)
└── home/default.nix (ユーザーレベル: Home Manager による dotfiles)
    ├── home/files/* (zshenv, zprofile, p10k.zsh, mise/config.toml, tmux.conf.local, custom oh-my-zsh plugins, wezterm configs)
    ├── home/fonts.nix (fonts: powerline-fonts, nerd-fonts)
    ├── home/git.nix (git 設定)
    ├── home/zsh.nix (zsh 設定)
    ├── home/oh-my-zsh.nix (oh-my-zsh, plugins, themes)
    ├── home/mise.nix (mise による開発ツール版管理)
    ├── home/tmux.nix (gpakosz/.tmux を使った tmux 設定)
    ├── home/ghostty.nix (ghostty ターミナル設定)
    └── home/wezterm.nix (wezterm ターミナル設定)
```

## 主要なアーキテクチャ上の決定

### 1. 環境変数

この flake を動かすには、`SYSTEM_USER` と `NIXBLD_GID` の環境変数が必要です。これらは Makefile で自動的に `export` される前提のため、`nix` コマンドを直接実行すると期待どおりに動かない場合があります。基本的には `make` コマンドを使ってください。

Git のユーザー設定も同様で、環境ごとの差し替えをしやすくするため、`GIT_USER_NAME` と `GIT_USER_EMAIL` を環境変数で受け取る設計にしています。

### 2. impure ビルド

既存システム設定との整合のため環境変数を読み取る必要があるため、すべてのビルドで `--impure` フラグを使用します。

### 3. ツール管理の分離

- **システムパッケージ**（git, mise, tmux, wezterm）: `darwin/default.nix` の nix-darwin で管理
- **GUI アプリ**（ghostty）: `darwin/default.nix` の Homebrew Cask で管理
- **開発ツール**（Java, Python, Node, Rust, Maven, Gradle など）: `home/files/mise/config.toml` の mise で管理

### 4. シェル設定

- **zsh と oh-my-zsh**: `home/zsh.nix` の Home Manager `programs.zsh` モジュールで宣言的に管理
- **zshenv と zprofile**: 環境変数設定のため `home/files/` で通常ファイルとして管理
- **oh-my-zsh カスタムプラグイン**: `home/files/oh-my-zsh/custom/plugins/` のユーザー定義プラグインを `~/.oh-my-zsh-custom/plugins/` にシンボリックリンク
- このハイブリッド方式により、コア設定は宣言的に管理しつつ、カスタムプラグインの柔軟性を維持

### 5. バックアップ戦略

`home/default.nix` の `backupFileExtension = "backup"` により、Home Manager が管理を引き継ぐ際に既存 dotfiles を `.backup` 拡張子で退避します。

## 設定変更

**重要**: どのファイルを変更した場合も、`make build` または `make apply` の前に必ず `git add` でステージしてください。Nix flake は Git 追跡対象ファイルだけを参照します。

### システムパッケージの追加

`darwin/default.nix` を編集:

```nix
environment.systemPackages = with pkgs; [
  git
  mise
  wezterm
  # ここに新しいパッケージを追加
];
```

次に:
```bash
git add darwin/default.nix
make apply
```

### 開発ツールの追加

`home/files/mise/config.toml` を編集:

```toml
[tools]
java = "temurin-21"
python = "latest"
node = "latest"
# ここに新しいツールを追加
```

次に:
```bash
git add home/files/mise/config.toml
make apply
make mise-install
```

### GUI アプリの追加

`darwin/default.nix` を編集:

```nix
homebrew = {
  enable = true;
  casks = [
    "ghostty"
    # ここに新しい cask を追加
  ];
};
```

次に:
```bash
git add darwin/default.nix
make apply
```

### シェル設定の変更

#### Zsh 基本設定

1. `home/zsh.nix` を編集し、zsh 設定（mise、editor など）を変更
2. 変更をステージ: `git add home/zsh.nix`
3. 反映: `make apply`
4. shell/tmux を再起動

#### oh-my-zsh 設定（プラグイン、テーマ）

1. `home/oh-my-zsh.nix` を編集し、oh-my-zsh 設定を変更
2. 変更をステージ: `git add home/oh-my-zsh.nix`
3. 反映: `make apply`
4. shell/tmux を再起動

#### 環境変数（zshenv、zprofile）

1. `home/files/` 内のファイル（zshenv、zprofile）を編集
2. 変更をステージ: `git add home/files/filename`
3. 反映: `make apply`
4. shell/tmux を再起動

#### Powerlevel10k テーマのカスタマイズ

1. `p10k configure` を実行し、新しい設定を生成
2. リポジトリへコピー: `cp ~/.p10k.zsh home/files/p10k.zsh`
3. ステージして反映: `git add home/files/p10k.zsh && make apply`

#### mise ツールバージョン

1. `home/files/mise/config.toml` を編集し、ツールバージョンを追加/更新
2. ステージして反映: `git add home/files/mise/config.toml && make apply`
3. ツールをインストール: `make mise-install`

### Git 設定の変更

**Git 基本設定**（`core.editor`, `color.ui`）は `home/git.nix` で宣言的に管理します。ユーザー固有設定（`user.name`, `user.email`）は環境変数で設定します。

**Git ユーザー設定の指定方法**:

Option 1: apply 前に環境変数を設定
```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your@email.com"
make apply
```

Option 2: コマンドライン引数として渡す
```bash
make apply GIT_USER_NAME="Your Name" GIT_USER_EMAIL="your@email.com"
```

Option 3: Makefile を編集してデフォルト値を設定
```makefile
# Makefile 内:
GIT_USER_NAME ?= Your Name
GIT_USER_EMAIL ?= your@email.com
```

その後 `make apply` を実行。

**注記**: 環境変数が未設定の場合、git の `user.name` と `user.email` は設定されません（既存設定は保持されます）。

### tmux 設定の変更

**tmux 設定**は [gpakosz/.tmux](https://github.com/gpakosz/.tmux) を使って管理しています。

1. **ベース設定を更新**（gpakosz/.tmux のバージョン）:
   - `home/tmux.nix` を編集して `rev` と `sha256` を更新
   - 最新ハッシュ取得: `nix-shell -p nix-prefetch-github --run 'nix-prefetch-github gpakosz .tmux'`
   - ステージして反映: `git add home/tmux.nix && make apply`

2. **設定をカスタマイズ**（prefix key、キーバインド、テーマ）:
   - `home/files/tmux.conf.local` を編集してカスタマイズ
   - `.tmux.conf` を**直接編集しないこと**（gpakosz/.tmux 管理対象）
   - ステージして反映: `git add home/files/tmux.conf.local && make apply`
   - tmux を再起動: `tmux kill-server && tmux`

3. **現在の設定でのキーバインド**:
   - Prefix key: `Ctrl-t`（デフォルト `Ctrl-b` から変更）
   - 横分割: `Ctrl-t` → `|`
   - 次のウィンドウ: `Ctrl-t` → `n` または `Space`
   - 前のウィンドウ: `Ctrl-t` → `Backspace`
   - コピーモード: `Ctrl-t` → `[`（Vi モード有効）

### 新しい dotfiles の追加

1. `home/files/` にファイルを作成
2. `home/default.nix` に追加:

```nix
home.file = {
  ".newfile".source = ./files/newfile;
};

# XDG config ファイルの場合:
xdg.configFile = {
  "appname/config.toml".source = ./files/appname/config.toml;
};
```

3. `git add` でステージしてから `make apply`

## 重要な注意点

### Git 追跡ファイルのみ

Nix flake が参照するのは Git 追跡ファイルのみです。新規・変更ファイルはビルド前に必ず `git add` を実行してください。ステージされていない変更は Nix から見えません。

### シェル再読み込み

シェル関連ファイルに影響する設定を適用した後は、tmux を完全再起動してください。

```bash
tmux kill-server
tmux
```

新しい tmux ウィンドウ（LEADER+c）を開くだけでは、環境は再読み込みされません。

### PATH 管理

この設定は、統一的なバージョン管理のため pyenv、nvm、asdf から mise へ移行済みです。PATH にこれら旧ツールのパスは含まれない前提です。古いツールのパスが PATH に残る場合は次を確認してください。

1. `.zprofile` - Homebrew、Toolbox、elan のみがあること
2. `.zshrc` - asdf、nvm、pyenv プラグインがないこと
3. `.zshenv` - cargo を存在時のみ条件付きで読み込むこと

### セキュリティチェック

gitleaks を含む pre-commit hook をインストールできます。

```bash
nix shell nixpkgs#pre-commit -c pre-commit install
```

### システム固有設定

この設定は **Apple Silicon（aarch64）のみ**を対象としています。Makefile はアーキテクチャを自動検出し、適切な設定名（`$USER-darwin`）を組み立てます。
