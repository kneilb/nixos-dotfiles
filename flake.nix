{
  description = "System flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay/master";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, emacs-overlay, ... } @ inputs:
    let 
      lib = nixpkgs.lib;

      pkgsOverride = (inputs: {
        nixpkgs = {
          overlays = [
            emacs-overlay.overlays.default
          ];
        };
      });
    in {
      nixosConfigurations = {
        beastie = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            pkgsOverride
            nixos-wsl.nixosModules.wsl
            home-manager.nixosModules.home-manager
            ./configuration.nix
          ];
        };
      };
    };
}
