{ pkgs, inputs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [
      inputs.nixpkgs-xr.packages.${pkgs.system}.proton-ge-rtsp-bin
    ];
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;
    autoStart = false;
  };

  hardware.graphics.enable32Bit = true;

  networking.firewall.allowedUDPPorts = [ 6969 ]; # SlimeVR
}
