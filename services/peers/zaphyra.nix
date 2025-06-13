{ ... }:
{
  systemd.network = {
    netdevs."50-zaphyra" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "zaphyra";
      };

      wireguardConfig = {
        PrivateKeyFile = "/etc/dn42keys/zaphyra";
        ListenPort = 21718;
      };

      wireguardPeers = [
        {
          PublicKey = "By49T/L7FjoLGmtp60qNI54EgzBZ8oImv9aveE2Ibms=";
          AllowedIPs = [ "fe80::/64" "fd00::/8" "0.0.0.0/0" ];
          PersistentKeepalive = 16;
          Endpoint = "router-a.dn42.zaphyra.eu:51824";
        }
      ];
    };

    networks."zaphyra" = {
      matchConfig.Name = "zaphyra";
      address = [ "fe80::706c:6569:6164:6573/64" ];

      routes = [{
        Destination = "fe80::6b61/128";
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
    protocol bgp zaphyra from dnpeers {
      neighbor fe80::6b61%zaphyra as 4242421718;
      enable extended messages;
      ipv4 { extended next hop on; };
      local role peer;
    }
  '';

  networking.firewall.allowedUDPPorts = [ 21718 ];
}
