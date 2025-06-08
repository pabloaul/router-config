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
        # my_bmp_collector = {
        #   collector_type = "Bmp";
        #   bind = "[::]:${toString bmpPort}";
        #   peers = {
        #     "192.0.2.1" = {};
        #   };
        # };
      };
    };
  };

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
