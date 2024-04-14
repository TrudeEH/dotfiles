# Home-Manager configuration

# man home-configuration.nix

{ config, pkgs, lib, ... }:

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

    # GUI Apps
    # obsidian # Broken as of now
    signal-desktop
    fragments
    element-desktop
    gnome-secrets
    newsflash
    timeshift
    eyedropper
    gnome-obfuscate
    gnome-podcasts

    # Note: Game packages like Steam and Prism should be installed through flatpak, or at system level.

    # CLI Apps
    nextcloud-client
    neofetch
    unzip
    eza

    # Note to self: This config does not include games/benchmarks. I'm using flatpak for those.

    gnomeExtensions.vitals
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

    (writeShellScriptBin "ncs" ''
      echo "+ Syncing Nextcloud @ ~/Nextcloud"
      mkdir ~/Nextcloud &> /dev/null
      if [[ -z "$1" ]]; then
        echo "USAGE: ncs <server_url>"
        exit 1
      fi
      nextcloudcmd -u $USER --path "/SYNC" ~/Nextcloud "$1"
    '')

    (writeShellScriptBin "reload" ''
      set -x
      nix-channel --update
      home-manager switch -b backup
      set +x
    '')

    (writeShellScriptBin "update" ''
      set -x
      if [ "$(uname -s)" = "Darwin" ]; then
        sudo softwareupdate -iaR
      else
        if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
          sudo timeshift --create
          sudo apt update
          sudo apt upgrade
          sudo apt dist-upgrade
          sudo apt autoremove
          sudo apt autoclean
          sudo journalctl --vacuum-time=7d
        elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
          sudo timeshift --create
          sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
          sudo pacman -Syu
          sudo pacman -Rsn $(pacman -Qdtq)
          echo "Selecting the fastest mirrors..."
          if [ ! "$(command -v reflector)" ]; then
            sudo pacman -Syu --noconfirm reflector rsync curl
          fi
          iso=$(curl -4 ifconfig.co/country-iso)
          extra="FR"
          sudo reflector -a 48 -c $iso -c $extra -f 5 -l 30 --verbose --sort rate --save /etc/pacman.d/mirrorlist
          echo "Cleaning pacman cache..."
          if [ ! "$(command -v paccache)" ]; then
            sudo pacman -Syu --noconfirm pacman-contrib
          fi
          paccache -rk1
          echo "Cleaning old logs..."
          sudo journalctl --vacuum-time=7d
        elif [ "$(grep -Ei 'fedora' /etc/*release)" ]; then
          sudo timeshift --create
          sudo dnf upgrade --refresh
          sudo dnf autoremove
          sudo journalctl --vacuum-time=7d
        else
          echo "Unknown distro, skipping system update."
        fi
      fi

      # Check if Flatpak is installed
      if [ "$(command -v flatpak)" ]; then
          flatpak update
          flatpak uninstall --unused --delete-data
      fi

      cd ~/dotfiles
      git pull

      nix-channel --update
      nix-collect-garbage --delete-older-than 7d
      home-manager switch
      set +x
    '')
  ];

  home.file = {
    # Allow unfree nix packages
    ".config/nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    ''; # Set file content as a string of text

    # Cursor theme fix
    ".icons/default".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic"; # Set file content as another file

    # Add new file option to nautilus
    "Templates/Text".text = "";
    "Templates/Markdown.md".text = "";
    "Templates/Script.sh".text = "#! /bin/bash";
  };

  home.sessionVariables = {
    EDITOR = "codium";
    PS1 = ''\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ '';
  };

  # =======================================================================
  # ----------------------- PROGRAM CONFIGURATION -------------------------
  # =======================================================================

  # Autostart services on boot
  # services.syncthing.enable = true;

  programs.home-manager.enable = true;

  # Default browser
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      DisablePocket = true;
      SearchBar = "unified";

      Preferences = {
        # Privacy settings
        "extensions.pocket.enabled" = false;
        "browser.topsites.contile.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.system.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    profiles.default = {
      id = 0;
      name = "Trude";
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:newtab";
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.order.1" = "DuckDuckGo";
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
        default = "DuckDuckGo";
        order = [ "DuckDuckGo" "Google" ];
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
              name = "Arch Linux";
              tags = [ "news" "wiki" "arch" ];
              url = "https://archlinux.org/";
            }
            {
              name = "NixOS Discourse";
              tags = [ "wiki" "nix" ];
              url = "https://discourse.nixos.org/";
            }
            {
              name = "GitHub";
              url = "https://github.com/";
            }
            {
              name = "WOL";
              url = "https://wol.jw.org/pt-PT/";
            }
            {
              name = "Rust Book";
              url = "https://doc.rust-lang.org/stable/book/";
            }
            {
              name = "Rust by example";
              url = "https://doc.rust-lang.org/stable/rust-by-example/";
            }
            {
              name = "Rustlings";
              url = "https://github.com/rust-lang/rustlings/";
            }
            {
              name = "Syncthing";
              url = "http://127.0.0.1:8384/#";
            }
          ];
        }
      ];
    };
  };

  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep ];
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 22;
    };

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  dconf.settings = {
    # GNOME settings
    # Use `dconf watch /` to track stateful changes you are doing, then set them here.
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disable-extension-version-validation = false;

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "Vitals@CoreCoding.com"
        "clipboard-indicator@tudmotu.com"
        # Add new extensions to the packages too! This section only enables extensions, not install them.
      ];

      favorite-apps = [
        "org.gnome.Epiphany.desktop"
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "md.obsidian.Obsidian.desktop"
        "codium.desktop"
        "org.gnome.Console.desktop"
        "io.gitlab.news_flash.NewsFlash.desktop"
        "org.gnome.Podcasts.desktop"
        "org.gnome.World.Secrets.desktop"
        "signal-desktop.desktop"
        "element-desktop.desktop"
      ];
    };

    "org/gnome/mutter" = {
      draggable-border-width = 20;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
    };

    "org/gnome/nautilus" = {
      "icon-view/default-zoom-level" = "small";
    };

    "org/gnome/Console" = {
      theme = "auto";
      audible-bell = false;
      use-system-font = false;
      custom-font = "JetBrainsMono Nerd Font 10";
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///${config.home.homeDirectory}/dotfiles/wallpapers/blobs-l.svg";
      picture-uri-dark = "file:///${config.home.homeDirectory}/dotfiles/wallpapers/blobs-d.svg";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
      #font-name = "";
      monospace-font-name = "JetBrainsMono Nerd Font Mono 10";
      #document-font-name = "";
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      cursor-theme = "Bibata-Modern-Classic";
      icon-theme = "Papirus";
    };

    "org/gnome/epiphany/web" = {
      enable-adblock = true;
      enable-popups = false;
      ask-on-download = true;
      enable-spell-checking = true;
      show-developer-actions = true;
      enable-itp = true;
      enable-website-data-storage = true;
      remember-passwords = false;
      use-gnome-fonts = false;
      monospace-font = "JetBrainsMono Nerd Font Mono 12";
    };

    "org/gnome/epiphany" = { # GNOME Web
      homepage-url = "about:newtab";
      start-in-incognito-mode = false;
      restore-session-policy = "always";
      use-google-search-suggestions = false;
      default-search-engine = "StartPage";

      search-engine-providers = with lib.hm.gvariant; [
        [
          (mkDictionaryEntry["url" (mkVariant "https://duckduckgo.com/?q=%s&t=epiphany")])
          (mkDictionaryEntry["bang" (mkVariant "!d")])
          (mkDictionaryEntry["name" (mkVariant "DuckDuckGo")])
        ]
        [
          (mkDictionaryEntry["url" (mkVariant "https://www.google.com/search?q=%s")])
          (mkDictionaryEntry["bang" (mkVariant "!g")])
          (mkDictionaryEntry["name" (mkVariant "Google")])
        ]
        [
          (mkDictionaryEntry["url" (mkVariant "https://search.nixos.org/packages?channel=23.11&from=0&size=50&sort=relevance&type=packages&query=%s")])
          (mkDictionaryEntry["bang" (mkVariant "!np")])
          (mkDictionaryEntry["name" (mkVariant "Nix Packages")])
        ]
        [
          (mkDictionaryEntry["url" (mkVariant "https://www.startpage.com/search?q=%s")])
          (mkDictionaryEntry["bang" (mkVariant "!s")])
          (mkDictionaryEntry["name" (mkVariant "StartPage")])
        ]
      ];

      content-filters = [
        "https://easylist-downloads.adblockplus.org/easylist_min_content_blocker.json"
        "https://better.fyi/blockerList.json"
        "https://github.com/AdguardTeam/BlockYouTubeAdsShortcut/blob/master/index.js"
      ];
    };

    "org/gnome/shell/extensions/vitals" = {
      hot-sensors = [
        "_memory_usage_"
        "__temperature_max__"
        "_processor_usage_"
      ];
      fixed-widths = false;
      update-time = 1;
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
      l = "eza -alhM --git --total-size --icons";
      ls = "eza --icons";
      ll = "eza -lhiM --git --total-size --icons --tree";
      tree = "eza --tree";
      grep = "batgrep";
      code = "codium";
      cat = "bat";
      man = "batman";
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
      ms-toolsai.jupyter
      ms-python.python
      arrterian.nix-env-selector
      piousdeer.adwaita-theme
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
      "git.autofetch" = true;
      # Styling
      "window.autoDetectColorScheme" = true;
      "workbench.colorTheme" = "Adwaita Dark";
      "workbench.preferredDarkColorTheme" = "Adwaita Dark";
      "workbench.preferredLightColorTheme" = "Adwaita Light";
      "workbench.iconTheme" = "material-icon-theme";
      "material-icon-theme.activeIconPack" = "none";
      "material-icon-theme.folders.theme" = "classic";
      "editor.fontLigatures" = true;
      # Other
      "telemetry.telemetryLevel" = "off";
      "update.showReleaseNotes" = false;
      "window.titleBarStyle" = "custom";
      "explorer.confirmDelete" = false;
    };
  };
}
