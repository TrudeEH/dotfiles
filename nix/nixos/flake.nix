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
      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };
      nixpkgs.config.allowUnfree = true;

      environment = {
        systemPackages = with pkgs; [ ];
        shells = with pkgs; [ zsh ];
      };

      users = {
        defaultUserShell = pkgs.zsh;
        users.trude = {
          isNormalUser = true;
          initialPassword = "trude";
          description = "TrudeEH";
          extraGroups = [ "networkmanager" "wheel" ];
        };
      };
      programs.zsh.enable = true;
      programs.steam.enable = true; #Home-manager steam installation crashes...

      home-manager = {
        extraSpecialArgs = {inherit inputs;};
        backupFileExtension = "backup";
        users = {
          "trude" = import ./home.nix;
        };
      };

      networking = {
        hostName = "trudeDev";
        networkmanager.enable = true;
        #firewall.allowedTCPPorts = [ ... ];
        #firewall.allowedUDPPorts = [ ... ];
      };

      services = {
        xserver = {
          enable = true;
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;
          xkb = {
            layout = "pt";
            variant = "";
          };
        };
        printing.enable = true;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          #jack.enable = true;
        };
        #openssh.enable = true;
      };

      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      virtualisation.libvirtd.enable = true;

      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        supportedFilesystems = ["ntfs"];
      };

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
