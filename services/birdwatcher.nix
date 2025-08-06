{ pkgs, ... }:
{
  services.birdwatcher = {
    enable = true;
    settings = ''
      [server]
      allow_from = []
      allow_uncached = false
      modules_enabled = [
        "status",
        "protocols",
        "protocols_bgp",
        "protocols_short",
        "routes_protocol",
        "routes_peer",
        "routes_table",
        "routes_table_filtered",
        "routes_table_peer",
        "routes_filtered",
        "routes_prefixed",
        "routes_noexport",
        "routes_pipe_filtered_count",
        "routes_pipe_filtered"
      ]

      [status]
      reconfig_timestamp_source = "bird"
      reconfig_timestamp_match = "# created: (.*)"

      filter_fields = []

      [bird]
      listen = "127.0.0.2:1312"
      config = "/etc/bird/bird.conf"
      birdc  = "${pkgs.bird3}/bin/birdc"
      ttl = 5 # time to live (in minutes) for caching of cli output

      [parser]
      filter_fields = []

      [cache]
      use_redis = false # if not using redis cache, activate housekeeping to save memory!

      [housekeeping]
      interval = 5
      force_release_memory = true

    '';
  };

  # services.nginx.virtualHosts."birdapi.net.nojus.org" = {
  #   locations."/".proxyPass = "http://127.0.0.2:1312/";
  #   useACMEHost = "net.nojus.org";
  #   addSSL = true;
  # };
}