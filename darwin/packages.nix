{ pkgs, repoRoot, ... }:
let
  darwinctl = pkgs.writeShellApplication {
    name = "darwinctl";
    runtimeEnv = {
      DARWINCTL_REPO_ROOT = repoRoot;
    };
    text = builtins.readFile ./files/darwinctl.sh;
  };

  # mise 2026.6.11 has a Darwin-only upstream test failure around special
  # permission bits in OCI layer metadata.
  miseNoCheck = pkgs.mise.overrideAttrs (_old: {
    doCheck = false;
  });
in
{
  environment.systemPackages = with pkgs; [
    awscli2
    git
    gh
    miseNoCheck
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
