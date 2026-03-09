{ pkgs, repoRoot, ... }:
let
  darwinctl = pkgs.writeShellApplication {
    name = "darwinctl";
    runtimeEnv = {
      DARWINCTL_REPO_ROOT = repoRoot;
    };
    text = builtins.readFile ./files/darwinctl.sh;
  };
in
{
  environment.systemPackages = with pkgs; [
    awscli2
    git
    gh
    mise
    uv
    neovim
    pkgs."terminal-notifier"
    fd
    ripgrep
    tmux
    wezterm
    elan
    kubectx
    k9s
    darwinctl
  ];
}
