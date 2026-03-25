{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (_final: prev: {
      # direnv 2.37.1 from current nixpkgs fails on aarch64-darwin because
      # it requests external linking while CGO is disabled by default.
      direnv = prev.direnv.overrideAttrs (old: {
        env = (old.env or { }) // {
          CGO_ENABLED = "1";
        };
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.stdenv.cc ];
      });
    })
  ];
}
