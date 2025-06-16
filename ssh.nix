{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      LogLevel = "VERBOSE";
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "10m";
    ignoreIP = [ ];
  };
}
