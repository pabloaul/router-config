{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.2";
        http_port = 3000;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.net.nojus.org";
      };
  
      analytics.reporting_enabled = false;
    };
  };

  services.nginx.virtualHosts."grafana.net.nojus.org" = {
    locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };

    useACMEHost = "net.nojus.org";
    forceSSL = true;
  };
}