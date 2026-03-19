# TrudePC-specific configuration
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../flakes/ai/nixos-module.nix
    ../../flakes/memory-optimizations/profiles/medium.nix
    ../../flakes/ups/nixos-module.nix
    ../../flakes/virtualisation/nixos-module.nix
    ../../flakes/gaming/nixos-module.nix
    {
      home-manager.users.trude.imports = [
        ../../flakes/ai/home-manager-module.nix
        ../../flakes/virtualisation/home-manager-module.nix
        ../../flakes/gaming/home-manager-module.nix
      ];
    }
  ];

  # Machine-specific settings
  networking.hostName = "TrudePC";
}
