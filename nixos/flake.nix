{
  description = "Trude's NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ai.url = "path:./flakes/ai";
    gaming.url = "path:./flakes/gaming";
    memoryOptimization.url = "path:./flakes/memory-optimizations";
    ups.url = "path:./flakes/ups";
    virtualisation.url = "path:./flakes/virtualisation";
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
