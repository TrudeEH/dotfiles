{
  description = "Trude's NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations = {
        TrudePC = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./hosts/TrudePC
          ];
        };

        live = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = "x86_64-linux";
          modules = [
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./hosts/live
            ./configuration.nix
          ];
        };

        # Add future machines here following the same pattern:
        # MachineName = nixpkgs.lib.nixosSystem {
        #   specialArgs = { inherit inputs; };
        #   modules = [
        #     ./common.nix
        #     ./hosts/MachineName
        #   ];
        # };
      };
    };
}
