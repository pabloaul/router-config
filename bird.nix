{ pkgs, lib, config, ... }:
{
  imports = [
    ./roa-dn42.nix
    ./peers/antibuilding.nix
  ];

  services.bird = {
      enable = true;
      package = pkgs.bird3;

      preCheckConfig = ''
        # Remove roa files for checking, because they are only available at runtime
        sed -i 's|include "/etc/bird/roa_dn42.conf";||' bird.conf
        sed -i 's|include "/etc/bird/roa_dn42_v6.conf";||' bird.conf

        cat -n bird.conf # here for debugging purposes
      '';

      config = lib.mkBefore ''
        log syslog { debug, trace, info, remote, warning, error, auth, fatal, bug };
        log stderr all;

        define OWNAS = 4242420069;
        define OWNNETv6 = fd42:deca:de::/48;
        define OWNNETSETv6 = [ fd42:deca:de::/48 ];
        define OWNIPv6 = fd42:deca:de::1;
        define OWNNET = 172.23.43.32/27;
        define OWNNETSET = [ 172.23.43.32/27 ];
        define OWNIP = 172.23.43.33;


        router id OWNIP;
        hostname "central";

        protocol device {
          scan time 10;
        }

        function is_self_net() -> bool {
          return net ~ OWNNETSET;
        }

        function is_self_net_v6() -> bool {
          return net ~ OWNNETSETv6;
        }

        function is_valid_network() -> bool {
          return net ~ [
            172.20.0.0/14{21,29}, # dn42
            172.20.0.0/24{28,32}, # dn42 Anycast
            172.21.0.0/24{28,32}, # dn42 Anycast
            172.22.0.0/24{28,32}, # dn42 Anycast
            172.23.0.0/24{28,32}, # dn42 Anycast
            172.31.0.0/16+,       # ChaosVPN
            10.100.0.0/14+,       # ChaosVPN
            10.127.0.0/16+,       # neonetwork
            10.0.0.0/8{15,24}     # Freifunk.net
          ];
        }

        function is_valid_network_v6() -> bool {
          return net ~ [
            fd00::/8{44,64} # ULA address space as per RFC 4193
          ];
        }

        roa4 table dn42_roa;
        roa6 table dn42_roa_v6;

        protocol static {
          roa4 { table dn42_roa; };
          include "/etc/bird/roa_dn42.conf";
        };

        protocol static {
          roa6 { table dn42_roa_v6; };
          include "/etc/bird/roa_dn42_v6.conf";
        };

        # dn42 default route
        protocol static {
          route OWNNET unreachable;

          ipv4 {
            import all;
            export none;
          };
        }

        protocol static  {
          route OWNNETv6 unreachable;

          ipv6 {
            import all;
            export none;
          };
        }

        protocol kernel {
          scan time 20;

          ipv4 {
            import none;
            export filter {
              if source = RTS_STATIC then reject;
              krt_prefsrc = OWNIP;
              accept;
            };
          };
        }

        protocol kernel {
          scan time 20;

          ipv6 {
            import none;
            export filter {
              if source = RTS_STATIC then reject; # dont export static routes
              krt_prefsrc = OWNIPv6; # preferred outgoing source address
              accept;
            };
          };
        };

        template bgp dnpeers {
          local as OWNAS;
          path metric 1;

          ipv4 {
            import filter {
              # dn42 default import: accept all prefixes from correct range and valid roa (excluding own network)
              if is_valid_network() && !is_self_net() then {
                if (roa_check(dn42_roa, net, bgp_path.last) != ROA_VALID) then {
                  # Reject when unknown or invalid according to ROA
                  print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                  reject;
                } else accept;
              } else reject;
            };

            export filter { if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; }; # dn42 default export: send static and bgp routes
            import limit 9000 action block; # block if import over 9000
          };

          ipv6 {
            import filter {
              if is_valid_network_v6() && !is_self_net_v6() then {
                if (roa_check(dn42_roa_v6, net, bgp_path.last) != ROA_VALID) then {
                  # Reject when unknown or invalid according to ROA
                  print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                  reject;
                } else accept;
              } else reject;
            };

            export filter { if is_valid_network_v6() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; };
            import limit 9000 action block;
          };
        }

      '';
    };
}
