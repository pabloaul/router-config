{ ... }:
{
  systemd.network = {
    netdevs."50-cyclopentane" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "cyclopentane";
      };

      wireguardConfig = {
        PrivateKeyFile = "/etc/dn42keys/cyclopentane";
        ListenPort = 23253;
      };

      wireguardPeers = [
        {
          PublicKey = "W+h0FMrxsAP7RppqFFMrfDHuu5CMW5aTW9E1MZXFf1w=";
          AllowedIPs = [ "fe80::/64" "fd00::/8" "0.0.0.0/0" ];
          PersistentKeepalive = 16;
          Endpoint = "imp.aidoskyneen.eu:49509";
        }
      ];
    };

    networks."cyclopentane" = {
      matchConfig.Name = "cyclopentane";
      address = [ "fe80::706c:6569:6164:6573/64" ];

      routes = [{
        Destination = "fe80::43:59:43";
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
    protocol bgp cyclopentane from dnpeers {
      neighbor fe80::43:59:43%cyclopentane as 4242423253;
      enable extended messages;
      ipv4 { extended next hop on; };
      local role peer;
    }
  '';

  networking.firewall.allowedUDPPorts = [ 23253 ];
}
