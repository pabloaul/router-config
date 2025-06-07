{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  systemd.network.enable = true;

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

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  system.stateVersion = "25.05";
}
