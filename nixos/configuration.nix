# Shared configuration across all machines
# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
# man configuration.nix

{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  nix.settings = {
    trusted-users = [ "root" ];
    allowed-users = [ "@wheel" ];
    sandbox = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  security.sudo.execWheelOnly = true;

  hardware.bluetooth.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
    options = "terminate:ctrl_alt_bksp";
  };

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # Define a user account.
  users.users.trude = {
    isNormalUser = true;
    description = "TrudeEH";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
    packages = with pkgs; [ ];
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "~";
    extraSpecialArgs = { inherit inputs; };
    users.trude.imports = [
      ./home.nix
    ];
  };

  # Packages
  nixpkgs.overlays = [
    (_final: prev: {
      rpi-imager = prev.rpi-imager.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (builtins.toFile "rpi-imager-fix-material-import.patch" ''
            diff --git a/src/wizard/WritingStep.qml b/src/wizard/WritingStep.qml
            index ad729ce..8ebf942 100644
            --- a/src/wizard/WritingStep.qml
            +++ b/src/wizard/WritingStep.qml
            @@ -5,6 +5,7 @@
             
             import QtQuick
             import QtQuick.Controls
            +import QtQuick.Controls.Material
             import QtQuick.Layouts
             import "../qmlcomponents"
          '')
        ];
      });
    })
  ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
  ];
  # system.autoUpgrade = {
  #   enable = true;
  #   flake = inputs.self.outPath;
  #   flags = [
  #     "--update-input"
  #     "nixpkgs"
  #     "-L"
  #   ];
  #   dates = "09:00";
  #   randomizedDelaySec = "45min";
  # };
  # Allow running executables
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add missing dynamic libraries for unpackaged executables here.
  ];
  services.tailscale.enable = true;

  hardware.graphics = {
    enable = true;
  };

  networking.firewall.enable = true;

  system.stateVersion = "25.11"; # Don't change after initial installation.

  # Fonts
  fonts = {
    fontconfig = {
      enable = true;
      allowBitmaps = true;
      useEmbeddedBitmaps = true; # Ensures bitmap fonts are used when available
    };
    # Install specific bitmap fonts
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      scientifica
      cozette
    ];
  };

}
