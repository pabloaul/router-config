{ ... }:
{
  systemd.network = {
    netdevs."50-grognozzle" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "grognozzle";
      };

      wireguardConfig = {
        PrivateKeyFile = "/etc/dn42keys/grognozzle";
        ListenPort = 20714;
      };

      wireguardPeers = [
        {
          PublicKey = "ZWwKge5AaGOvWjde7CbjeftDI2UXetdLjgz7FuyvymE=";
          AllowedIPs = [ "fe80::/64" "fd00::/8" "0.0.0.0/0" ];
          PersistentKeepalive = 16;
        }
      ];
    };

    networks."grognozzle" = {
      matchConfig.Name = "grognozzle";
      address = [ "fe80::706c:6569:6164:6573/64" ];

      routes = [{
        Destination = "fe80::574:12";
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
    protocol bgp grognozzle from dnpeers {
      neighbor fe80::574:12%grognozzle as 4242420714;
      enable extended messages;
      ipv4 { extended next hop on; };
      local role peer;
    }
  '';

  networking.firewall.allowedUDPPorts = [ 20714 ];
}
