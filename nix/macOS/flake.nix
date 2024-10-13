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
        sharedModules = [
          mac-app-util.homeManagerModules.default
        ];
      };

      environment.systemPackages = [];

      security.pam.enableSudoTouchIdAuth = true;

      system.defaults = {
        # https://daiderd.com/nix-darwin/manual/index.html

        ActivityMonitor = {
          IconType = 5;
          SortColumn = "CPUUsage";
          SortDirection = 0;
        };

        CustomUserPreferences = {
          "com.apple.Safari" = {
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
          };
        };

        NSGlobalDomain = {
          AppleICUForce24HourTime = false;
          AppleInterfaceStyle = "Dark";
          AppleScrollerPagingBehavior = true;
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          NSDocumentSaveNewDocumentsToCloud = false;
          NSWindowShouldDragOnGesture = true;
          KeyRepeat = 2;
          "com.apple.mouse.tapBehavior" = 1; #Tap to click on mouse.
          "com.apple.swipescrolldirection" = false; #Normal scrolling.

        };

        WindowManager = {
          EnableStandardClickToShowDesktop = true;
          StandardHideDesktopIcons = false;
        };


        alf = {
          globalstate = 1; #Firewall
          stealthenabled = 1; #Drop incoming ping requests
        };

        dock = {
          autohide = false;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.5; #Dock autohide animation speed
          expose-animation-duration = 0.5; #Mission Control animation speed
          minimize-to-application = true; #Minimize windows into their application icon

          persistent-apps = [ #Dock apps
            "/Applications/Safari.app"
            "/System/Applications/Utilities/Terminal.app"
          ];

          persistent-others = [ #Dock folders
            "~/Downloads"
          ];

          show-recents = false; #Dock show ecent apps
          showhidden = true;
          static-only = true; #Show only open apps in dock
          tilesize = 32; #Dock icon size
        };


        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXDefaultSearchScope = "SCcf"; #Search defaults to current folder
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv"; #Default to list view
          ShowPathbar = true;
          ShowStatusBar = true;
          _FXSortFoldersFirst = true;
        };

        loginwindow.GuestEnabled = false;

        menuExtraClock = {
          Show24Hour = false;
          ShowAMPM = true;
          ShowDayOfMonth = true;
        };

        screencapture.disable-shadow = true;
        screensaver.askForPassword = true;

        trackpad.Clicking = true; #Tap to click
        trackpad.Dragging = true;
      };

      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };

    intel = { pkgs, config, ... }: {
      nixpkgs.hostPlatform = "x86_64-darwin";
    };

    apple-silicon = { pkgs, config, ... }: {
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ nix run nix-darwin -- switch --flake ~/.config/nix-darwin
    darwinConfigurations.default = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        apple-silicon
        inputs.mac-app-util.darwinModules.default
        inputs.home-manager.darwinModules.default
      ];
    };
    darwinConfigurations.x86 = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        intel
        inputs.mac-app-util.darwinModules.default
        inputs.home-manager.darwinModules.default
      ];
    };
    darwinPackages = self.darwinConfigurations.default.pkgs;
  };
}
