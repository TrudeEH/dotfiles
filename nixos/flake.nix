{
  description = "Trude's NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    agent-skills-nix.url = "github:Kyure-A/agent-skills-nix";
    anthropics-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
    bigboss-claude = {
      url = "github:0xbigboss/claude-code";
      flake = false;
    };
    lihaoze-skills = {
      url = "github:lihaoze123/my-skills";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      mkHost =
        hostPath:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            hostPath
          ];
        };
    in
    {
      nixosConfigurations = {
        TrudePC = mkHost ./hosts/TrudePC;
        TrudeLaptop = mkHost ./hosts/TrudeLaptop;

        live = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./hosts/live
            ./configuration.nix
          ];
        };
      };
    };
}
