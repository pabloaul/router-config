{ ... }:
{
  services.bird-lg = {
    proxy = {
      enable = true;
      allowedIPs = [ "127.0.0.1" ];
      listenAddress = "127.0.0.2:8000";
    };

    frontend = {
      enable = true;
      netSpecificMode = "dn42";
      servers = [ "central" ];
      domain = "net.nojus.org";
      listenAddress = "127.0.0.2:5000";
      proxyPort = 8000;
      protocolFilter = [ "bgp" "static" ];
      whois = "whois.dn42";
      navbar = {
        brand = "pleiades";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 5000 ];

  services.nginx.virtualHosts."bird-lg.net.nojus.org" = {
    locations."/".proxyPass = "http://127.0.0.2:5000/";
    useACMEHost = "net.nojus.org";
    forceSSL = true;
  };
}
