{ lib, ... }:

{
  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "openclaw"
    ];

  networking.firewall.allowedTCPPorts = [ 11434 ]; # LMStudio
}
