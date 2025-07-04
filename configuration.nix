{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./ssh.nix
    ./networking.nix
    ./services
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.qemuGuest.enable = true;

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
    btop
    dig
    dnsutils
    git
    micro
    nmap
    tcpdump
    wget
    whois
    wireguard-tools
  ];

  programs.mtr.enable = true;

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
