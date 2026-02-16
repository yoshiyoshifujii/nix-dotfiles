{
  description = "yoshiyoshifujii's dotfiles - nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
    let
      # デフォルトユーザー (nix-darwin用)
      # 環境変数 SYSTEM_USER が必須。設定されていない場合はエラー
      defaultUser =
        let systemUser = builtins.getEnv "SYSTEM_USER";
        in if systemUser != ""
           then systemUser
           else builtins.throw "SYSTEM_USER environment variable is not set. Please run via Makefile or set SYSTEM_USER manually.";

      # nixbld グループ GID を環境変数から読み込み（未設定はエラー）
      nixbldGid =
        let gidStr = builtins.getEnv "NIXBLD_GID";
        in if gidStr != ""
           then builtins.fromJSON gidStr
           else builtins.throw "NIXBLD_GID environment variable is not set. Please run via Makefile or set NIXBLD_GID manually.";

      # Git設定を環境変数から読み込み（Makefile が config.nix から読み込む）
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
