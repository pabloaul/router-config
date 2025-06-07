{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./ssh.nix
      ./networking.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  system.stateVersion = "25.05";
}
