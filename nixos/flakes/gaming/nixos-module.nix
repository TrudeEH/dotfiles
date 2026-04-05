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

  programs.nix-ld.libraries = with pkgs; [
    # Unity dependencies for the VRChat creator toolchain.
    stdenv.cc.cc.lib
    icu
    zlib
    glib
    gtk3
    pango
    cairo
    atk
    gdk-pixbuf
    libx11
    libxext
    libxcursor
    libxrandr
    libxi
    libxcomposite
    libxdamage
    libxfixes
    libxrender
    libxtst
    alsa-lib
    dbus
    fontconfig
    freetype
    nss
    nspr
    expat
    libuuid
    libGL
    libGLU
    vulkan-loader
    wayland
    libxkbcommon
    libxml2_13
    libxcb
    libpulseaudio
    systemd
    libcap
    libsecret
    cups
  ];
}
