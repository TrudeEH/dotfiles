# TrudeLaptop-specific configuration
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../flakes/ai/nixos-module.nix
    ../../flakes/gnome/nixos-module.nix
    ../../flakes/memory-optimizations/high.nix
    ../../flakes/virtualisation/nixos-module.nix
    ../../flakes/gaming/nixos-module.nix
    ../../flakes/hacking/nixos-module.nix
    {
      home-manager.users.trude.imports = [
        ../../flakes/ai/home-manager-module.nix
        ../../flakes/gnome/home-manager-module.nix
        ../../flakes/virtualisation/home-manager-module.nix
        ../../flakes/gaming/home-manager-module.nix
        ../../flakes/hacking/home-manager-module.nix
      ];
    }
  ];

  networking.hostName = "TrudeLaptop";
}
