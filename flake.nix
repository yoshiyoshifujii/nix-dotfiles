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
      # 環境変数 DARWIN_USER が必須。設定されていない場合はエラー
      defaultUser =
        let envUser = builtins.getEnv "DARWIN_USER";
        in if envUser != ""
           then envUser
           else builtins.throw "DARWIN_USER environment variable is not set. Please run via Makefile or set DARWIN_USER manually.";

      # Git設定を環境変数から読み込み（空の場合はnull）
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
