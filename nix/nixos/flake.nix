{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    configuration = { lib, config, pkgs, inputs, ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [ ];

      users.users.trude = {
        isNormalUser = true;
        initialPassword = "trude";
        description = "TrudeEH";
        extraGroups = [ "networkmanager" "wheel" ];
      };

      # Home-manager module.
      home-manager = {
        extraSpecialArgs = {inherit inputs;};
        backupFileExtension = "backup";
        users = {
          "trude" = import ./home.nix;
        };
      };

      # Network.
      networking.hostName = "trudeDev";
      networking.networkmanager.enable = true;

      # GNOME.
      services.xserver.enable = true;
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Enable sound with pipewire.
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        #jack.enable = true;
      };

      # System Services.
      # services.openssh.enable = true;

      # Firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];

      # System options.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
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
      services.xserver.xkb = {
        layout = "pt";
        variant = "";
      };
      system.stateVersion = "24.05";
    };
  in
  {
    # Build darwin flake using:
    # $ sudo nixos-rebuild switch --flake /etc/nixos#default
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hardware-configuration.nix
        configuration
        inputs.home-manager.nixosModules.default
      ];
    };
  };
}
