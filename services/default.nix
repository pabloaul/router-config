{ ... }:
{
  imports = [
    ./nginx.nix
    ./bird.nix
    ./bird-lg.nix
    ./fernglas.nix
    ./grafana.nix
    ./prometheus.nix
    ./pleiades.nix
    ./unbound.nix
    ./weechat.nix
  ];
}