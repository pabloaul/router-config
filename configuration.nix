{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./ssh.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  systemd.network = {
    enable = true;

    networks."10-wan" = {
      matchConfig.Name = "ens3";
      address = [ 
        "89.58.50.220/22"
        "2a03:4000:68:5::1/64"
      ];
      routes = [
        { Gateway = "89.58.48.1"; }
        { Gateway = "fe80::1"; }
      ];

      linkConfig.RequiredForOnline = "routable";
    };
  };

  networking = {
    hostName = "central";
    domain = "net.nojus.org";
    firewall.enable = true;
    useNetworkd = true;
  };

  time.timeZone = "Europe/Amsterdam";
  console.keyMap = "de";

  users.users.nojus = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHjNNOWsxM3X/YRL6JmMhoPGp3zhv/0JPZQRUFP9LCv nojus@merope"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    micro
    wget
  ];

  system.stateVersion = "25.05";
}
