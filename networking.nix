{ pkgs, lib, config, ... }:
{
  imports = [
    ./bird.nix
  ];

  systemd.network.enable = true;

  networking = {
    hostName = "central";
    domain = "net.nojus.org";
    firewall.enable = true;
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

  # dummy network (dn42)
  systemd.network.netdevs."50-pleiades" = {
    netdevConfig = {
      Kind = "dummy";
      Name = "pleiades";
    };
  };

  systemd.network.networks."pleiades" = {
    matchConfig.Name = "pleiades";

    address = [
      "172.23.43.33/27"
      "fd42:deca:de::1/48"
    ];

    networkConfig = {
      IPv4Forwarding = true;
      IPv6Forwarding = true;
    };
  };
}
