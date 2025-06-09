{ pkgs, lib, config, ... }:
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv6.conf.all.forwarding" = true;
  };

  systemd.network.enable = true;

  networking = {
    hostName = "central";
    domain = "net.nojus.org";
    firewall.enable = true;
    firewall.checkReversePath = false;
    useNetworkd = true;
   };

  # netcup uplink
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens3";

    address = [
      "89.58.50.220/22"
      "2a03:4000:68:5::1/64"
    ];

    routes = [
      { Gateway = "89.58.48.1"; }
      { Gateway = "fe80::1"; }
    ];

    linkConfig.RequiredForOnline = "routable";
  };
}
