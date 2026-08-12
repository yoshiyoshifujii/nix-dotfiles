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
  # mise 2026.7.17's vendored libz-ng-sys build script invokes `cmake`
  # directly, which isn't on PATH without adding it as a build input.
  miseNoCheck = pkgs.mise.overrideAttrs (old: {
    doCheck = false;
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.cmake ];
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
