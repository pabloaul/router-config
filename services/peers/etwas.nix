{ ... }:
{
  systemd.network = {
    netdevs."50-etwas" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "etwas";
      };

      wireguardConfig = {
        PrivateKeyFile = "/etc/dn42keys/etwas";
        ListenPort = 22264;
      };

      wireguardPeers = [
        {
          PublicKey = "xFAzy1zfgNoraLipU3Ru6G0NJ39UiM+WWZOjLmEy4DQ=";
          AllowedIPs = [ "fe80::/64" "fd00::/8" "0.0.0.0/0" ];
          PersistentKeepalive = 16;
          Endpoint = "ncvps.dn42.etwas.me:22267";
        }
      ];
    };

    networks."etwas" = {
      matchConfig.Name = "etwas";
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
    protocol bgp etwas from dnpeers {
      neighbor fe80::acab%etwas as 4242422264;
      enable extended messages;
      ipv4 { extended next hop on; };
      local role peer;
    }
  '';

  networking.firewall.allowedUDPPorts = [ 22264 ];
}
