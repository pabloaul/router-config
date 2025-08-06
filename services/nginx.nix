{ ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx.virtualHosts."nojus.org" = {
    locations."/".root = "/var/www/net";
    useACMEHost = "nojus.org";
    forceSSL = true;
  };

  services.nginx.virtualHosts."net.nojus.org" = {
    locations."/".root = "/var/www/net";
    useACMEHost = "net.nojus.org";
    forceSSL = true;
  };  

  services.nginx.virtualHosts."lg.net.nojus.org" = {
    locations."/".root = "/var/www/lg";
    useACMEHost = "net.nojus.org";
    forceSSL = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "router+acme@nojus.org";
    certs."net.nojus.org" = {
      domain = "*.net.nojus.org";
      extraDomainNames = [ "net.nojus.org" ];
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/secrets/cloudflare.secret";
    };
    certs."nojus.org" = {
      domain = "*.nojus.org";
      extraDomainNames = [ "nojus.org" ];
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/secrets/cloudflare.secret";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}