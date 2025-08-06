{ config, pkgs,  ... }:
{
  services.weechat = {
    enable = true;
  };

  users.users.weechat = {
    isSystemUser = true;
    home = "${config.services.weechat.root}";
    extraGroups = [ "weechat" ];
  };
}