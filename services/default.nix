{ ... }:
{
  imports = [
    ./nginx.nix
    ./bird.nix
    ./bird-lg.nix
    ./fernglas.nix
    ./pleiades.nix
  ];
}