{ pkgs, username, ... }:
{
  system.primaryUser = username;

  programs.zsh.enable = true;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  system.stateVersion = 4;
}
