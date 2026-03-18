{
  description = "AI modules for Trude's NixOS and Home Manager setup";

  outputs = _:
    {
      nixosModules.default = import ./nixos-module.nix;
      homeManagerModules.default = import ./home-manager-module.nix;
    };
}
