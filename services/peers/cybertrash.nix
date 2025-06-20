{ ... }:
{
  systemd.network = {
    netdevs."50-cybertrash" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "cybertrash";
      };

      wireguardConfig = {
        PrivateKeyFile = "/etc/dn42keys/cybertrash";
        ListenPort = 20663;
      };

      wireguardPeers = [
        {
          PublicKey = "NxHkdwZPVL+3HdrHTFOslUpUckTf0dzEG9qpZ0FTBnA=";
          AllowedIPs = [ "fe80::/64" "fd00::/8" "0.0.0.0/0" ];
          PersistentKeepalive = 16;
        }
      ];
    };

    networks."cybertrash" = {
      matchConfig.Name = "cybertrash";
      address = [ "fe80::706c:6569:6164:6573/64" ];

      routes = [{
        Destination = "fe80::acab/128";
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
    protocol bgp cybertrash from dnpeers {
      neighbor fe80::acab%cybertrash as 4242420663;
      enable extended messages;
      ipv4 { extended next hop on; };
      local role peer;
    }
  '';

  networking.firewall.allowedUDPPorts = [ 20663 ];
}