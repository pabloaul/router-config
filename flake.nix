{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    fernglas = {
      url = "github:wobcom/fernglas";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fernglas, ... }@inputs: {
     nixosConfigurations.central = nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";
       specialArgs = { inherit inputs; };
       modules = [ ./configuration.nix ];
    };
  };
}