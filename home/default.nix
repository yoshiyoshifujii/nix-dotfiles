{ config, pkgs, username, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${username} = { ... }: {
      home.username = username;
      home.stateVersion = "24.05";
      home.sessionVariables = {
        LANG = "ja_JP.UTF-8";
      };
      home.file = {
        ".zshenv".source = ./files/zshenv;
        ".zprofile".source = ./files/zprofile;
        # .zshrc は home/zsh.nix で programs.zsh により自動生成される
        ".oh-my-zsh-custom/plugins/origin" = {
          source = ./files/oh-my-zsh/custom/plugins/origin;
          recursive = true;
        };
        ".oh-my-zsh-custom/plugins/zsh-history-beginning-search" = {
          source = ./files/oh-my-zsh/custom/plugins/zsh-history-beginning-search;
          recursive = true;
        };
      };

      xdg.configFile = {
        "mise/config.toml".source = ./files/mise/config.toml;
        # mise activation は home/zsh.nix で直接実行
      };

      imports = [
        ./ghostty.nix
        ./wezterm.nix
        ./zsh.nix
      ];
    };
  };
}
