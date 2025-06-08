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
          peers = {
            "fd42:deca:de::1" = {};
          };
        };
      };
    };
  };

  services.bird.config = ''
    protocol bmp {
      system name "central";
      system description "pleiades_bmp";
      local address fd42:deca:de::1;
      station address ip ::1 port 11019;

      monitoring rib in pre_policy on;
      monitoring rib in post_policy on;

      tx buffer limit 96;
    }
  '';

  services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."lg.net.nojus.org" = {
        #enableACME = true;
        #forceSSL = true;
        locations."/".root = fernglas.packages.${config.nixpkgs.hostPlatform.system}.fernglas-frontend;
        locations."/api/".proxyPass = "http://${config.services.fernglas.settings.api.bind}";
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
}
