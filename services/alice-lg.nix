{ ... }:
{
  # depends on birdwatcher.nix
  services.alice-lg = {
    enable = true;
    settings = {
      server = {
        # configures the built-in webserver and provides global application settings
        listen_http = "127.0.0.2:7340";
        #enable_prefix_lookup = true;
        asn = 4242420069;
      };

      "source.central" = {
        name = "central.net.nojus.org";
      };

      "source.central.birdwatcher" = {
        api = "http://127.0.0.2:1312";
        type = "multi_table";
        peer_table_prefix = "T";
        pipe_protocol_prefix = "M";
      };

    };

  };

  services.nginx.virtualHosts."alice-lg.net.nojus.org" = {
    locations."/".proxyPass = "http://127.0.0.2:7340/";
    useACMEHost = "net.nojus.org";
    addSSL = true;
  };
}