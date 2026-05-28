{
  description = "yoshiyoshifujii's dotfiles - nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
    let
      # ── 共通 ──────────────────────────────────────────────────
      # ユーザー名（darwin / home 共通。必須）
      defaultUser =
        let systemUser = builtins.getEnv "SYSTEM_USER";
        in if systemUser != ""
           then systemUser
           else builtins.throw "SYSTEM_USER environment variable is not set. Please run via Makefile or set SYSTEM_USER manually.";

      # ── darwin 系 ─────────────────────────────────────────────
      # nixbld グループ GID（必須）
      nixbldGid =
        let gidStr = builtins.getEnv "NIXBLD_GID";
        in if gidStr != ""
           then builtins.fromJSON gidStr
           else builtins.throw "NIXBLD_GID environment variable is not set. Please run via Makefile or set NIXBLD_GID manually.";

      # リポジトリルートパス（darwinctl に焼き込む。必須）
      repoRoot =
        let path = builtins.getEnv "DARWIN_REPO_ROOT";
        in if path != ""
           then path
           else builtins.throw "DARWIN_REPO_ROOT environment variable is not set. Please run via Makefile.";

      # ── home 系 ───────────────────────────────────────────────
      # Git 設定（Makefile が .env から読み込む。任意）
      gitUserName =
        let name = builtins.getEnv "GIT_USER_NAME";
        in if name != "" then name else null;

      gitUserEmail =
        let email = builtins.getEnv "GIT_USER_EMAIL";
        in if email != "" then email else null;

      # macOS (Apple Silicon)
      system = "aarch64-darwin";
    in {
      # ============================================================
      # nix-darwin Configurations (macOS system-level)
      # ============================================================
      darwinConfigurations = {
        "${defaultUser}-darwin" = nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            {
              _module.args.username = defaultUser;
              _module.args.nixbldGid = nixbldGid;
              _module.args.gitUserName = gitUserName;
              _module.args.gitUserEmail = gitUserEmail;
              _module.args.repoRoot = repoRoot;
            }
            ./darwin/default.nix
            ./home/default.nix
            home-manager.darwinModules.home-manager
          ];
        };
      };

      darwinPackages = self.darwinConfigurations."${defaultUser}-darwin".pkgs;
    };
}
