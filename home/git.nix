{ config, pkgs, gitUserName, gitUserEmail, ... }:
let
  # flake.nix から注入された git 設定（null でない場合のみ追加）
  userConfig =
    (if gitUserName != null then { user.name = gitUserName; } else {}) //
    (if gitUserEmail != null then { user.email = gitUserEmail; } else {});
in
{
  programs.git = {
    enable = true;
    settings = {
      core = {
        editor = "vim -c \"set fenc=utf-8\"";
      };
      color = {
        ui = true;
      };
      credential = {
        helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
    } // userConfig;
  };
}
