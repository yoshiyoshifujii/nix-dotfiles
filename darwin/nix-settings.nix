{ nixbldGid, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  ids.gids.nixbld = nixbldGid;
}
