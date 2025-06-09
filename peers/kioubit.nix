{ ... }:
{
  systemd.network = {
    netdevs."50-kioubit" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "kioubit";
      };

      wireguardConfig = {
        PrivateKeyFile = "/etc/dn42keys/kioubit";
        ListenPort = 23914;
      };

      wireguardPeers = [
        {
          PublicKey = "B1xSG/XTJRLd+GrWDsB06BqnIq8Xud93YVh/LYYYtUY=";
          AllowedIPs = [ "fe80::/64" "fd00::/8" "0.0.0.0/0" ];
          PersistentKeepalive = 16;
          Endpoint = "de2.g-load.eu:20069";
        }
      ];
    };

    networks."kioubit" = {
      matchConfig.Name = "kioubit";
      address = [ "fe80::ade1/64" ];

      routes = [{
        Destination = "fe80::ade0/128";
      }];

      linkConfig = {
        RequiredForOnline = "no";
      };

      networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv4ReversePathFilter = "no";
        IPv6AcceptRA = false;
        DHCP = false;
      };
    };
  };

  services.bird.config = ''
    protocol bgp kioubit from dnpeers {
      neighbor fe80::ade0%kioubit as 4242423914;
      enable extended messages;
      ipv4 { extended next hop on; };
    }
  '';

  networking.firewall.allowedUDPPorts = [ 23914 ];
}
