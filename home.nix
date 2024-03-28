# man home-configuration.nix

{ config, pkgs, ... }:

{
  # =======================================================================
  # ----------------------- HOME & INSTALLED PACKAGES ---------------------
  # =======================================================================

  home.username = "trude";
  # home.homeDirectory = "/Users/trude"; #macOS
  home.homeDirectory = "/home/trude"; #Linux
  home.stateVersion = "23.11"; # Do NOT change. This value stays the same when updating.

  home.packages = with pkgs; [
    # Packages to install:
    obsidian
    signal-desktop
    fragments

    # Note to self: This config does not include games/benchmarks. I'm using flatpak for those.

    gnomeExtensions.vitals
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-indicator

    # Override nerdfont to install JetBrains only.
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    # Shel scripts:
    (writeShellScriptBin "extract" ''
      if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar e $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
    '')

    (writeShellScriptBin "reload" ''
      nix-channel --update
      echo "rebuilding home.nix..."
      home-manager switch &> switch.log || (cat switch.log | grep --color error && false)
    '')

    (writeShellScriptBin "update" ''
      if [ "$(uname -s)" = "Darwin" ]; then
        echo "Updating macOS..."
        echo "THE DEVICE WILL RESTART IF NECESSARY."
        sudo softwareupdate -iaR
      else
        if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
          echo "Updating Debian..."
          sudo apt update
          sudo apt upgrade
          sudo apt dist-upgrade
          sudo apt autoremove
          sudo apt autoclean
          sudo journalctl --vacuum-time=7d
        elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
          echo "Updating Arch..."
          sudo pacman -Syu
          sudo pacman -Rsn $(paru -Qdtq)
          if p c pacman-contrib &>/dev/null; then
              paccache -rk1
          else
              sudo pacman -S pacman-contrib
              paccache -rk1
          fi
          sudo journalctl --vacuum-time=7d
        elif [ "$(grep -Ei 'fedora' /etc/*release)" ]; then
          echo "Updating Fedora..."
          sudo dnf upgrade --refresh
          sudo dnf autoremove
          sudo journalctl --vacuum-time=7d
          flatpak update
        else
          echo "Unknown distro, skipping system update."
        fi
      fi

      nix-channel --update
      nix-collect-garbage --delete-older-than 7d
      home-manager switch
    '')
  ];

  home.file = {
    # Allow unfree nix packages
    ".config/nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    ''; # Set file content as a string of text

    # Cursor theme fix
    ".icons/default".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic"; # Set file content as another file
  };

  home.sessionVariables = {
    EDITOR = "codium";
    PS1 = ''\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ '';
  };

  # =======================================================================
  # ----------------------- PROGRAM CONFIGURATION -------------------------
  # =======================================================================

  programs.home-manager.enable = true;

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Trude";
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:newtab";
        "browser.search.defaultenginename" = "Google";
        "browser.search.order.1" = "Google";
        "general.smoothScroll" = true;
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "dom.security.https_only_mode" = true;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
      };
      search = {
        force = true;
        default = "Google";
        order = [ "Google" "DuckDuckGo" ];
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS Wiki" = {
            urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
          "Bing".metaData.hidden = true;
          "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
        };
      };
      bookmarks = [
        {
          name = "Toolbar";
          toolbar = true;
          bookmarks = [
            {
              name = "Gmail";
              tags = [ "gmail" ];
              keyword = "gmail";
              url = "https://mail.google.com/mail";
            }
            {
              name = "YouTube";
              url = "https://www.youtube.com/";
            }
            {
              name = "NixOS Wiki";
              tags = [ "wiki" "nix" ];
              url = "https://nixos.wiki/";
            }
          ];
        }
      ];
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 22;
    };

    iconTheme = {
      name = "Tela-circle";
      package = pkgs.tela-circle-icon-theme;
    };
  };

  dconf.settings = {
    # GNOME settings
    # Use `dconf watch /` to track stateful changes you are doing, then set them here.
    "org/gnome/shell" = {
      disable-user-extensions = false;

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "Vitals@CoreCoding.com"
        "blur-my-shell@aunetx"
        "appindicatorsupport@rgcjonas.gmail.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        # Add new extensions to the packages too! This section only enables extensions, not install them.
      ];

      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "codium.desktop"
        "org.gnome.Terminal.desktop"
        "obsidian.desktop"
        "signal-desktop.desktop"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///usr/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///usr/share/backgrounds/gnome/blobs-d.svg";
    };

    "org/gnome/shell/extensions/vitals" = {
      hot-sensors = [
        "_memory_usage_"
        "__temperature_max__"
        "_processor_usage_"
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "TrudeEH";
    userEmail = "ehtrude@gmail.com";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      code = "codium";
    };
    initExtra = "set completion-ignore-case On";
    bashrcExtra = ''
      export EDITOR="codium";
      export PS1="\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ ";
    '';
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;

    # Extensions
    extensions = (with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      mhutchie.git-graph
      pkief.material-icon-theme
      oderwat.indent-rainbow
      bierner.emojisense
      jnoortheen.nix-ide
      ritwickdey.liveserver
      github.vscode-pull-request-github
    ]);

    # Settings
    userSettings = {
      # General
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace', monospace";
      "terminal.integrated.fontSize" = 12;
      "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace', monospace";
      "window.zoomLevel" = 0.1;
      "editor.multiCursorModifier" = "ctrlCmd";
      "workbench.startupEditor" = "none";
      "explorer.compactFolders" = false;
      # Whitespace
      "files.trimTrailingWhitespace" = true;
      "files.trimFinalNewlines" = true;
      "files.insertFinalNewline" = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      # Git
      "git.enableCommitSigning" = false;
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      # Styling
      "window.autoDetectColorScheme" = true;
      "workbench.preferredDarkColorTheme" = "Default Dark Modern";
      "workbench.preferredLightColorTheme" = "Default Light Modern";
      "workbench.iconTheme" = "material-icon-theme";
      "material-icon-theme.activeIconPack" = "none";
      "material-icon-theme.folders.theme" = "classic";
      "editor.fontLigatures" = true;
      # Other
      "telemetry.telemetryLevel" = "off";
      "update.showReleaseNotes" = false;
      "window.titleBarStyle" = "custom";
    };
  };
}
