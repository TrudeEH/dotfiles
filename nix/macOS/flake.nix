{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    }

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { lib, pkgs, config, inputs, ... }: {
      services.nix-daemon.enable = true;
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.config.allowUnfree = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;

      # Home-manager module.
      home-manager.users.trude = import ./home.nix;

      # Configs
      environment.systemPackages = [
        pkgs.mkalias
      ];

      system.activationScripts.applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
        '';

      # Configure macOS
      system.defaults = {
        # man 5 configuration.nix
        dock.autohide = true;
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
      }

      # nixpkgs.hostPlatform = "x86_64-darwin"; # aarch64-darwin for ARM
    };
  in
  {
    # Build darwin flake using:
    # $ nix run nix-darwin -- switch --flake ~/.config/nix-darwin
    darwinConfigurations.default = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        inputs.home-manager.nixosModules.default
      ];
    };
    darwinPackages = self.darwinConfigurations.default.pkgs;
  };
}
