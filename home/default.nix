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
        ".p10k.zsh".source = ./files/p10k.zsh;
      };

      imports = [
        ./fonts.nix
        ./ghostty.nix
        ./wezterm.nix
        ./tmux.nix
        ./zsh.nix
        ./oh-my-zsh.nix
        ./mise.nix
      ];
    };
  };
}
