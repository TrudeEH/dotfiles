{ ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    autoStart = false;
  };

  hardware.graphics.enable32Bit = true;

  networking.firewall.allowedUDPPorts = [ 6969 ]; # SlimeVR
}
