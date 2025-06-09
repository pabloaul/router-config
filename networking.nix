{ pkgs, lib, config, ... }:
{
  imports = [
    ./bird.nix
    ./fernglas.nix
  ];

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

  # client network
  networking.firewall.allowedUDPPorts = [51820];

  systemd.network.netdevs."50-pleiades" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "pleiades";
    };

    wireguardConfig = {
      PrivateKeyFile = "/etc/pleiades/hostkey";
      ListenPort = 51820;
    };

    wireguardPeers = [
      {
        PublicKey = "dvJYIrYjPKLX/lJArTnapvQLPpQ6RstabpaFOQp/uFc="; # merope
        AllowedIPs = [ "fd42:deca:de::500/128" ]; # no ipv4 for now
      }
      {
        PublicKey = "0SkA0XyQUszwM7hNoAZtNL5mY3yAQIlBGmkiGzys034="; # nodservice
        AllowedIPs = [ "fd42:deca:de::1000/128" ];
      }
    ];
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

  # dn42 dns split tunnel
  systemd.network.networks."10-wan" = {
    networkConfig.DNSDefaultRoute = false;

    dns = [
      "fd42:d42:d42:53::1"
      "fd42:d42:d42:54::1"
      "172.20.0.53"
      "172.23.0.53"
    ];

    domains = [
      "~dn42"
      "~20.172.in-addr.arpa"
      "~21.172.in-addr.arpa"
      "~22.172.in-addr.arpa"
      "~23.172.in-addr.arpa"
      "~10.in-addr.arpa"
      "~d.f.ip6.arpa"
    ];
  };
}
