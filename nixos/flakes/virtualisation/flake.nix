{
  description = "Virtualisation module for Trude's NixOS hosts";

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
