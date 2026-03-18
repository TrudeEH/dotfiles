{
  description = "UPS module for Trude's NixOS hosts";

  outputs = _:
    {
      nixosModules.default = import ./nixos-module.nix;
    };
}
