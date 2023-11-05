{ inputs, ... }:

let inherit (inputs)
  home-manager
  nixpkgs;
in
{
  flake = {
    nixosConfigurations = {
      "nixosLaptop" = import ./nixos-laptop { inherit nixpkgs home-manager; };
    };
  };
}
