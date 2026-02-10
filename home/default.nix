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
      home.file = {
        ".zshenv".source = ./files/zshenv;
        ".zshrc".source = ./files/zshrc;
        ".oh-my-zsh/custom/plugins/origin" = {
          source = ./files/oh-my-zsh/custom/plugins/origin;
          recursive = true;
          force = true;
        };
        ".oh-my-zsh/custom/plugins/zsh-history-beginning-search" = {
          source = ./files/oh-my-zsh/custom/plugins/zsh-history-beginning-search;
          recursive = true;
          force = true;
        };
      };

      xdg.configFile = {
        "mise/config.toml".source = ./files/mise/config.toml;
        "zsh/mise.zsh".source = ./files/zsh/mise.zsh;
      };

      imports = [
        ./ghostty.nix
        ./wezterm.nix
      ];
    };
  };
}
