{ config, ... }:
{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.2";
    retentionTime = "90d";

    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [ "textfile" ];
      };

      bird = {
        enable = true;
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "bird";
        static_configs = [{
          targets = [ "localhost:${toString config.services.prometheus.exporters.bird.port}" ];
        }];
      }
    ];
  };
}