{
  description = "System flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }:
    let
      lib = nixpkgs.lib;
    in {
    nixosConfigurations = {
      beastie = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          ./configuration.nix
        ];
      };
    };
  };
}
