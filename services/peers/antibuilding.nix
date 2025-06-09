{ ... }:
{
  systemd.network = {
    netdevs."50-antibuilding" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "antibuilding";
      };

      wireguardConfig = {
        PrivateKeyFile = "/etc/dn42keys/antibuilding";
        ListenPort = 21403;
      };

      wireguardPeers = [
        {
          PublicKey = "7lS7x+2NVx7FQgdN6qpioF8nJn95mBkctv3Gg4h/lDA=";
          AllowedIPs = [ "fe80::/64" "fd00::/8" "0.0.0.0/0" ];
          PersistentKeepalive = 30;
          Endpoint = "decade.dn42.antibuild.ing:5241";
        }
      ];
    };

    networks."antibuilding" = {
      matchConfig.Name = "antibuilding";
      address = [ "fe80::8943:2034:2342/64" ];

      routes = [{
        Destination = "fe80::1234:9320/128";
      }];

      networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv4ReversePathFilter = "no";
        IPv6AcceptRA = false;
        DHCP = false;
      };

      linkConfig = {
        RequiredForOnline = "no";
      };
    };
  };

  services.bird.config = ''
    protocol bgp antibuilding from dnpeers {
      neighbor fe80::1234:9320%antibuilding as 4242421403;
      enable extended messages;
      ipv4 { extended next hop on; };
    }
  '';

  networking.firewall.allowedUDPPorts = [ 21403 ];
}
