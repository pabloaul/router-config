{ ... }:
{
  networking.firewall.allowedUDPPorts = [ 51820 ];

  # client network
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
      {
        PublicKey = "mYeJ9bxIAwjTX9dbIs0wYY04Rcs7R66JTy3jVAGyQSI="; # lexi
        AllowedIPs = [ "fd42:deca:de:7381::/64" ];
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