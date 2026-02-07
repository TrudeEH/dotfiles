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

  nix.settings.trusted-users = [
    "root"
    "trude"
  ];

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

  # Enable Wayland
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
    options = "terminate:ctrl_alt_bksp";
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
  ];
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "09:00";
    randomizedDelaySec = "45min";
  };
  # Allow running executables
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add missing dynamic libraries for unpackaged executables here.
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.tailscale.enable = true;

  # Steam and VR
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

  # Set up virtualisation
  virtualisation.libvirtd.enable = true;

  # UPS (Green Cell 2000VA)
  power.ups = {
    enable = true;
    mode = "standalone";
    ups.greencell = {
      driver = "nutdrv_qx";
      port = "auto";
      description = "Green Cell UPS 2000VA";
      directives = [
        "vendorid = 0001"
        "productid = 0000"
      ];
    };
    users.upsmon = {
      passwordFile = "${pkgs.writeText "upsmon-password" "upsmonpass"}";
      upsmon = "primary";
      instcmds = [ "ALL" ];
    };
    upsmon.monitor.greencell = {
      user = "upsmon";
    };
  };

  # RAM Optimizations (important for AI workloads)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # Total "virtual" swap size. 100% of RAM is safe for zRAM.
    memoryPercent = 100; # Drop to 50% if 64+GB of RAM
  };
  services.earlyoom = {
    enable = true;
    # Start killing processes when available RAM drops below 10%
    freeMemThreshold = 10; # Drop to 5% if 64+GB of RAM, increase if on <16GB RAM.
    # Start killing processes when available swap drops below 10%
    freeSwapThreshold = 10;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
    # Helps prevent the system from "stuttering" when it starts swapping
    "vm.watermark_boost_factor" = 0;
  };

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 11434 ]; # LMStudio (must be manually configured)
  networking.firewall.allowedUDPPorts = [ 6969 ]; # SlimeVR

  system.stateVersion = "25.11"; # Don't change after initial installation.

}
