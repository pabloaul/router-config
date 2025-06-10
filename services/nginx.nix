{ pkgs, config, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx.virtualHosts."net.nojus.org" = {
    #enableACME = true;
    #forceSSL = true;
    locations."/".root = "/var/www/net";
  };

  services.nginx.virtualHosts."lg.net.nojus.org" = {
    #enableACME = true;
    #forceSSL = true;
    locations."/".root = "/var/www/lg";
  };
}