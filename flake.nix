{
  description = "yoshiyoshifujii's dotfiles - nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, ... }@inputs:
    let
      # デフォルトユーザー (nix-darwin用)
      defaultUser = "yoshiyoshifujii";

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
            ./darwin/default.nix
          ];
        };
      };

      darwinPackages = self.darwinConfigurations."${defaultUser}-darwin".pkgs;
    };
}
