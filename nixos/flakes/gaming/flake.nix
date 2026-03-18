{
  description = "Gaming modules for Trude's NixOS and Home Manager setup";

  outputs = _:
    {
      nixosModules = {
        default = import ./nixos-module.nix;
        trude = {
          imports = [
            ./nixos-module.nix
          ];

          home-manager.users.trude.imports = [
            ./home-manager-module.nix
          ];
        };
      };
      homeManagerModules.default = import ./home-manager-module.nix;
    };
}
