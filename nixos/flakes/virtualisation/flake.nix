{
  description = "Virtualisation module for Trude's NixOS hosts";

  outputs = _:
    {
      nixosModules.default = import ./nixos-module.nix;
      homeManagerModules.default = import ./home-manager-module.nix;
    };
}
