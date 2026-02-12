{ config, pkgs, ... }:
let
  # 環境変数から直接読み込み（空の場合はnull）
  gitUserName =
    let name = builtins.getEnv "GIT_USER_NAME";
    in if name != "" then name else null;

  gitUserEmail =
    let email = builtins.getEnv "GIT_USER_EMAIL";
    in if email != "" then email else null;

  # 環境変数から取得したgit設定（nullでない場合のみ追加）
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
    } // userConfig;
  };
}
