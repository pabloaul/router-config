{ ... }:
{
  # otherwise resolved stub listener clashes with unbound on localhost
  services.resolved.extraConfig = ''DNSStubListener=no'';

  services.unbound = {
    enable = true;

    settings = {
      interface = [ "2a03:4000:68:5::53" ];

      access-control = [
        "127.0.0.1/8 allow" # local only until i get back to this
        "::1/128 allow"
      ];

      
    };
  };
}