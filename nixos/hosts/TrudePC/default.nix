# TrudePC-specific configuration
{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.ai.nixosModules.trude
    inputs.memoryOptimization.nixosModules.medium
    inputs.ups.nixosModules.default
    inputs.virtualisation.nixosModules.trude
    inputs.gaming.nixosModules.trude
  ];

  # Machine-specific settings
  networking.hostName = "TrudePC";
}
