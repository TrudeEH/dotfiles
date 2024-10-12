# man home-configuration.nix
{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf optionals;
  inherit (pkgs.stdenv) isLinux isDarwin; #GNOME on Linux
  userName = "trude";
in
{
  # =======================================================================
  # ----------------------- HOME & INSTALLED PACKAGES ---------------------
  # =======================================================================

  home.username = userName;
  home.homeDirectory = if isLinux then "/home/${userName}" else "/Users/${userName}";
  home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    google-chrome
    gh
    unzip
    fastfetch
    prismlauncher

    # Override nerdfont to install JetBrains only.
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    # Shell Scripts
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

    (writeShellScriptBin "pushall" ''
      if [[ -z "$1" ]]; then
      echo "Usage: pushall \"commit message\""
      else
        git pull
        git diff
        read -p "Press ENTER to continue..."
        git add -A
        git commit -m "$@"
        git push
      fi
    '')

    (writeShellScriptBin "update" ''
      nix-channel --update
      if command -v nixos-rebuild 2>&1 >/dev/null; then
        sudo nixos-rebuild switch --recreate-lock-file --flake /etc/nixos#default
      elif command -v darwin-rebuild 2>&1 >/dev/null; then
        sudo softwareupdate -i -a
        nix run nix-darwin -- switch --recreate-lock-file --flake ~/.config/nix-darwin#default
      else
        home-manager -b backup switch
      fi
    '')
  ]
  # Linux-only apps
  ++ optionals isLinux [eyedropper gnome-terminal epiphany gnome-podcasts impression gnome-boxes adw-gtk3 gnomeExtensions.vitals gnomeExtensions.appindicator gnomeExtensions.caffeine gnomeExtensions.search-light]
  # macOS-only apps
  ++ optionals isDarwin [];

  # Cursor theme fix (Linux)
  home.file = mkIf isLinux {
    ".icons/default".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic"; # Set file content as another file
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # =====================================================
  # -------------------- LINUX --------------------------
  # =====================================================
  gtk = mkIf isLinux {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 22;
    };

    # iconTheme = {
    #   name = "Papirus";
    #   package = pkgs.papirus-icon-theme;
    # };
  };

  dconf.settings = with lib.hm.gvariant; mkIf isLinux {
    "org/gnome/Console" = {
      theme = "auto";
      use-system-font = true;
    };

    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "programming";
      number-format = "automatic";
      show-thousands = false;
      show-zeroes = false;
      source-currency = "";
      source-units = "degree";
      target-currency = "";
      target-units = "radian";
      word-size = 64;
    };

    "org/gnome/desktop/a11y/interface" = {
      high-contrast = false;
      show-status-shapes = false;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = false;
    };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    "org/gnome/desktop/input-sources" = {
      current = mkUint32 0;
      mru-sources = [ (mkTuple [ "xkb" "pt" ]) (mkTuple [ "xkb" "pt" ]) ];
      sources = [ (mkTuple [ "xkb" "pt" ]) ];
      xkb-options = [ "caps:ctrl_modifier" ];
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-seconds = false;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-animations = true;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-theme = "adw-gtk3-dark";
      locate-pointer = false;
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      overlay-scrolling = true;
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = 30;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
      report-technical-problems = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///usr/share/backgrounds/gnome/blobs-l.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/search-providers" = {
      enabled = [ "org.gnome.Weather.desktop" ];
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Calculator.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.Characters.desktop" "org.gnome.clocks.desktop" ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 300;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = true;
      theme-name = "__custom";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,close";
      resize-with-right-button = true;
      visual-bell = false;
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

    "org/gnome/epiphany/web" = {
      show-developer-actions = true;
    };

    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = true;
      enable-spellchecking = true;
      inverted-colors = false;
      show-sidebar = true;
      sidebar-page = "thumbnails";
      sidebar-size = 132;
      sizing-mode = "automatic";
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/mutter" = {
      center-new-windows = true;
      edge-tiling = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [];
      toggle-tiled-right = [];
    };

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "small";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = mkUint32 2410;
      sleep-inactive-ac-timeout = 3600;
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      enabled-extensions = [ "caffeine@patapon.info" "appindicatorsupport@rgcjonas.gmail.com" "Vitals@CoreCoding.com" "gtk4-ding@smedius.gitlab.com" "blur-my-shell@aunetx" "search-light@icedman.github.com" ];
      favorite-apps = [];
      last-selected-power-profile = "performance";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dash-max-icon-size = 34;
      dock-fixed = false;
      dock-position = "BOTTOM";
      extend-height = false;
    };

    "org/gnome/shell/extensions/ding" = {
      check-x11wayland = true;
      icon-size = "small";
      show-home = false;
    };

    "org/gnome/shell/extensions/vitals" = {
      fixed-widths = false;
      hot-sensors = [ "_memory_usage_" "_processor_usage_" "__temperature_max__" ];
      icon-style = 1;
      use-higher-precision = false;
    };

    "org/gnome/shell/extensions/search-light" = {
      background-color = mkTuple [ 0.1411764770746231 0.1411764770746231 0.1411764770746231 1.0 ];
      blur-background=false;
      border-radius=5.7443946188340806;
      border-thickness=0;
      currency-converter=true;
      entry-font-size=1;
      scale-height=0.10000000000000001;
      scale-width=0.10000000000000001;
      unit-converter=true;
      window-effect=0;
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/system/location" = {
      enabled = true;
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      background-color = "rgb(0,0,0)";
      backspace-binding = "auto";
      exit-action = "hold";
      font = "JetBrainsMono Nerd Font 12";
      foreground-color = "rgb(208,207,204)";
      use-system-font = false;
      use-theme-colors = true;
    };
  };

  # Default browser
  xdg.mimeApps = mkIf isLinux {
    enable = true;
    defaultApplications = {
      "text/html" = "org.gnome.Epiphany.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
    };
  };


  # ===========================================================
  # -------------------- Independent --------------------------
  # ===========================================================

  # Autostart services on boot
  services.gnome-keyring.enable = isLinux;
  programs.home-manager.enable = true;

  programs.firefox = {
    enable = false;
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
      name = "TrudeEH";
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
        default = "Startpage";
        order = [ "Startpage" "DuckDuckGo" "Google" ];
        engines = {
          "Startpage" = {
            urls = [{
              template = "https://www.startpage.com/do/search?query={searchTerms}";
            }];
            definedAliases = [ "@s" ];
          };
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
          ];
        }
      ];
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];
    # Use the Nix package search engine to find
    # even more plugins : https://search.nixos.org/packages
  };

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    disableConfirmationPrompt = true;
    escapeTime = 250;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs; [ tmuxPlugins.cpu ];
    prefix = "C-s";
    terminal = "tmux-256color";

    extraConfig = ''
      bind-key C command-prompt -p "Name of new window: " "new-window -n '%%'"

      # hjkl pane traversal
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # easy reload config
      bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded."

      # set window split
      bind-key v split-window -h -c "#{pane_current_path}"
      bind-key b split-window -v -c "#{pane_current_path}"

      # Styling
      set-option -g status-position top
      set -g mode-style "fg=black,bg=orange"
      set-option -g pane-border-style fg=colour236
      set-option -g pane-active-border-style fg=orange
      set-window-option -g window-status-current-style fg=orange,bg=default,bright
      set-window-option -g window-status-style fg=colour244,bg=default
      set-window-option -g clock-mode-colour orange
      set-option -g status-style "bg=default,fg=white"
      set-option -g status-left ""
      set-option -g status-right '[Session: #S] [CPU: #{cpu_fg_color}#{cpu_percentage}#[default]] [RAM: #{ram_fg_color}#{ram_percentage}#[default]] %d#[dim]/#[default]%m#[dim]/#[default]%Y %I:%M#[dim]%P#[default]'
      set -g status-interval 1
      set -g status-right-length 60

      set -g @cpu_high_fg_color "#[fg=#FF0000]"
      set -g @ram_high_fg_color "#[fg=#FF0000]"
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
    '';
  };

  programs.git = {
    enable = true;
    userName = "TrudeEH";
    userEmail = "ehtrude@gmail.com";
    aliases = {
      a = "add";
      c = "commit";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      cl = "clone";
      cm = "commit -m";
      co = "checkout";
      cp = "cherry-pick";
      cpx = "cherry-pick -x";
      d = "diff";
      f = "fetch";
      fo = "fetch origin";
      fu = "fetch upstream";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      pl = "pull";
      pr = "pull -r";
      ps = "push";
      psf = "push -f";
      rb = "rebase";
      rbi = "rebase -i";
      r = "remote";
      ra = "remote add";
      rr = "remote rm";
      rv = "remote -v";
      rs = "remote show";
      st = "status";
    };
    extraConfig = {
      pull = {
        rebase=true;
      };
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      l = "ls -alh";
      ls = "ls --color=auto";
      ll = "ls -lhi";
      grep = "grep --color=auto";
      ta = "tmux attach";
      t = "tmux";
      v = "nvim";
      cpp = "rsync -ah --progress";
      code = "codium --enable-features=UseOzonePlatform --ozone-platform=wayland";
      neofetch = "fastfetch";
      sudo = "sudo -i";
      ns = "nix-shell";
    };
    initExtra = "set completion-ignore-case On";
    bashrcExtra = ''
      set -o vi
      export EDITOR="nvim";
      export PS1="\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ ";

      if [[ -z $TMUX ]]; then
        tmux attach
        if [[ $? == 1 ]]; then
          tmux new -s main
        fi
      fi
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
      jnoortheen.nix-ide
      ritwickdey.liveserver
      github.vscode-pull-request-github
      arrterian.nix-env-selector
      piousdeer.adwaita-theme
      llvm-vs-code-extensions.vscode-clangd
      formulahendry.code-runner
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
      "workbench.tree.indent" = 12;
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
      "window.commandCenter" = true;
      "workbench.productIconTheme" = "adwaita";
      "editor.renderLineHighlight" = "none";
      # Other
      "telemetry.telemetryLevel" = "off";
      "update.showReleaseNotes" = false;
      "window.titleBarStyle" = "custom";
      "explorer.confirmDelete" = false;
    };
  };
}
