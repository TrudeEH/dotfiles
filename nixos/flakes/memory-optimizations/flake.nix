{
  description = "Memory optimization profiles for Trude's NixOS hosts";

  outputs = _:
    {
      nixosModules = {
        low = import ./profiles/low.nix;
        medium = import ./profiles/medium.nix;
        high = import ./profiles/high.nix;
      };
    };
}
