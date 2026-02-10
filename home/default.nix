{ config, pkgs, username, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = { ... }: {
      home.username = username;
      home.stateVersion = "24.05";
      home.sessionVariables = {
        LANG = "ja_JP.UTF-8";
      };

      home.file.".zshenv".source = ./files/zshenv;

      xdg.configFile."mise/config.toml".source = ./files/mise/config.toml;

      xdg.configFile."zsh/mise.zsh".source = ./files/zsh/mise.zsh;

      imports = [
        ./ghostty.nix
        ./wezterm.nix
      ];
    };
  };
}
