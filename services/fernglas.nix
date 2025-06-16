{ pkgs, system, config, ... }:
let
  fernglas = builtins.getFlake "github:wobcom/fernglas";
in
{
  imports = [
    fernglas.nixosModules.default
  ];

  services.fernglas = {
    enable = true;
    settings = {
      api.bind = "[::1]:3000";
      collectors = {
        bmp_central = {
          collector_type = "Bmp";
          bind = "[::1]:11019";
          peers."fd42:deca:de::1".name_override = "central";
        };
        bgp_central = {
          collector_type = "Bgp";
          bind = "[::1]:1179";
          peers."fd42:deca:de::1" = {
            asn = 4242420069;
            router_id = "172.23.43.32";
            name_override = "central";
            add_path = true;
            route_state = "Accepted";
          };
        };
      };
    };
  };

  services.bird.config = ''
    protocol bmp {
      system name "central_bmp";
      system description "pleiades monitoring";
      local address fd42:deca:de::1;
      station address ip ::1 port 11019;

      monitoring rib in pre_policy on;
      monitoring rib in post_policy on;

      tx buffer limit 96;
    }

    protocol bgp fernglas {
      local as 4242420069;
        source address fd42:deca:de::1;
        neighbor ::1 port 1179 as 4242420069;
        multihop 64;
        rr client;
        advertise hostname on;

        ipv6 {
          import keep filtered;
          import table on;
          export table on;
          add paths tx;
          import filter { reject; };
          export filter { accept; };
          next hop keep on;
        };

        ipv4 {
          import keep filtered;
          import table on;
          export table on;
          add paths tx;
          import filter { reject; };
          export filter { accept; };
          extended next hop on;
        };
    }
  '';

  services.nginx.virtualHosts."fernglas.net.nojus.org" = {
    locations."/".root = fernglas.packages.${config.nixpkgs.hostPlatform.system}.fernglas-frontend;
    locations."/api/".proxyPass = "http://${config.services.fernglas.settings.api.bind}";
    useACMEHost = "net.nojus.org";
    forceSSL = true;
  };
}
