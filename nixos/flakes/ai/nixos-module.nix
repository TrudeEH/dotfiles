{ lib, pkgs, ... }:

{
  nixpkgs.config.allowInsecurePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "openclaw"
    ];

  systemd.services.openclaw = {
    description = "OpenClaw Gateway";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      HOME = "/home/trude";
    };
    serviceConfig = {
      Type = "simple";
      User = "trude";
      Group = "users";
      WorkingDirectory = "/home/trude";
      ExecStart = "${pkgs.openclaw}/bin/openclaw gateway run";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  networking.firewall.allowedTCPPorts = [ 11434 ]; # LMStudio
}
