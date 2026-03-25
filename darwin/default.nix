{ ... }:
{
  imports = [
    ./overlays.nix
    ./nix-settings.nix
    ./packages.nix
    ./homebrew.nix
    ./security.nix
    ./user.nix
  ];
}
