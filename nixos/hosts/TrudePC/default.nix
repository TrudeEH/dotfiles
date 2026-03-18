# TrudePC-specific configuration
{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.ai.nixosModules.default
    inputs.memoryOptimization.nixosModules.medium
    inputs.ups.nixosModules.default
    inputs.virtualisation.nixosModules.default
    inputs.gaming.nixosModules.default
  ];

  home-manager.users.trude.imports = [
    inputs.virtualisation.homeManagerModules.default
    inputs.ai.homeManagerModules.default
    inputs.gaming.homeManagerModules.default
  ];

  # Machine-specific settings
  networking.hostName = "TrudePC";
}
