{ config, pkgs, username, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = { ... }: {
      home.username = username;
      home.stateVersion = "24.05";

      imports = [
        ./ghostty.nix
        ./wezterm.nix
      ];
    };
  };
}
