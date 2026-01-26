# TrudePC-specific configuration
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Machine-specific settings
  networking.hostName = "TrudePC";
}
