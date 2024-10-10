{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fix an issue where home-manager apps are not indexed on Spotlight
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util }:
  let
    configuration = { pkgs, config, ... }: {
      services.nix-daemon.enable = true;
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.config.allowUnfree = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;

      # Home-manager module
      users.users.trude = {
        name = "trude";
        home = "/Users/trude";
      };
      home-manager = {
        extraSpecialArgs = {inherit inputs;};
        backupFileExtension = "backup";
        users = {
          "trude" = import ./home.nix;
        };
      };
      home-manager.sharedModules = [
        mac-app-util.homeManagerModules.default
      ];

      # System packages
      environment.systemPackages = [];

      # Configure macOS
      security.pam.enableSudoTouchIdAuth = true;
      system.defaults = {
        # https://daiderd.com/nix-darwin/manual/index.html
        ActivityMonitor.IconType = 5;
        ActivityMonitor.SortColumn = "CPUUsage";
        ActivityMonitor.SortDirection = 0;
        CustomUserPreferences = {
          "com.apple.Safari" = {
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
          };
        };
        NSGlobalDomain.AppleICUForce24HourTime = false;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.AppleScrollerPagingBehavior = true;
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleShowAllFiles = true;
        NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
        NSGlobalDomain.NSWindowShouldDragOnGesture = true;
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain."com.apple.mouse.tapBehavior" = 1; #Tap to click on mouse.
        NSGlobalDomain."com.apple.swipescrolldirection" = false; #Normal scrolling.
        WindowManager.EnableStandardClickToShowDesktop = true;
        WindowManager.StandardHideDesktopIcons = false;
        alf.globalstate = 1; #Firewall
        alf.stealthenabled = 1; #Drop incoming ping requests
        dock.autohide = false;
        dock.autohide-delay = 0;
        dock.autohide-time-modifier = 0.5; #Dock autohide animation speed
        dock.expose-animation-duration = 0.5; #Mission Control animation speed
        dock.minimize-to-application = true; #Minimize windows into their application icon
        dock.persistent-apps = [ #Dock apps
          "/Applications/Safari.app"
          "/System/Applications/Utilities/Terminal.app"
        ];
        dock.persistent-others = [ #Dock folders
          "~/Downloads"
        ];
        dock.show-recents = false; #Dock show ecent apps
        dock.showhidden = true;
        dock.static-only = true; #Show only open apps in dock
        dock.tilesize = 32; #Dock icon size
        finder.AppleShowAllExtensions = true;
        finder.AppleShowAllFiles = true;
        finder.FXDefaultSearchScope = "SCcf"; #Search defaults to current folder
        finder.FXEnableExtensionChangeWarning = false;
        finder.FXPreferredViewStyle = "Nlsv"; #Default to list view
        finder.ShowPathbar = true;
        finder.ShowStatusBar = true;
        finder._FXSortFoldersFirst = true;
        loginwindow.GuestEnabled = false;
        menuExtraClock.Show24Hour = false;
        menuExtraClock.ShowAMPM = true;
        menuExtraClock.ShowDayOfMonth = true;
        screencapture.disable-shadow = true;
        screensaver.askForPassword = true;
        trackpad.Clicking = true; #Tap to click
        trackpad.Dragging = true;
      };
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };

      nixpkgs.hostPlatform = "x86_64-darwin"; # aarch64-darwin for ARM
    };
  in
  {
    # Build darwin flake using:
    # $ nix run nix-darwin -- switch --flake ~/.config/nix-darwin
    darwinConfigurations.default = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        inputs.mac-app-util.darwinModules.default
        inputs.home-manager.darwinModules.default
      ];
    };
    darwinPackages = self.darwinConfigurations.default.pkgs;
  };
}
