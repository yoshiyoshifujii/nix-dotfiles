{ config, pkgs, username, gitUserName, gitUserEmail, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit gitUserName gitUserEmail;
    };
    users.${username} = { ... }: {
      home.username = username;
      home.stateVersion = "24.05";
      home.sessionPath = [ "$HOME/bin" ];
      home.sessionVariables = {
        LANG = "ja_JP.UTF-8";
      };
      home.file = {
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
        ./git.nix
        ./neovim.nix
        ./macskk.nix
      ];
    };
  };
}
