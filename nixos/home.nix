# man home-configuration.nix
{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.username = "trude";
  home.homeDirectory = "/home/trude";
  home.stateVersion = "25.11"; # Do not change after initial installation.

  home.packages = with pkgs; [
    nixfmt
    nil
    bat

    google-chrome
    localsend
    #stremio
    element-desktop

    # Dev tools
    vscode
    nodejs
    python3

    # Gnome Extensions
    gnomeExtensions.caffeine
    gnomeExtensions.vitals
    gnomeExtensions.appindicator
    # gnomeExtensions.blur-my-shell

    # Gnome Apps
    file-roller
    commit
    binary
    resources
    raider
    gnome-podcasts
    gnome-obfuscate
    collision
    switcheroo
    wordbook
    textpieces
    gnome-sound-recorder
    eyedropper
    icon-library

    # Scripts
    (pkgs.writeShellScriptBin "colors" ''
      #! /bin/bash

      for i in {0..255}; do
          printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
          if ((i == 15)) || ((i > 15)) && (((i - 15) % 6 == 0)); then
              printf "\n"
          fi
      done
    '')
    (pkgs.writeShellScriptBin "gitssh" ''
      #! /bin/sh

      current_url=$(git remote get-url origin)
      if echo "$current_url" | grep -q '^git@'; then
        echo "Remote origin already uses SSH."
        exit 0
      fi

      ssh_url=$(echo "$current_url" | sed -E 's|https?://([^/]+)/(.+)|git@\1:\2|')
      echo "Changing remote origin from $current_url to $ssh_url"
      git remote set-url origin "$ssh_url"
    '')
    (pkgs.writeShellScriptBin "rebuild" ''
      #! /bin/bash

      set -e
      GRAY='\e[90m'
      ORANGE='\e[38;5;214m'
      RESET='\e[0m'

      pushd ~/dotfiles > /dev/null
      git diff -U0 *.nix
      echo -e "''${ORANGE}NixOS Rebuilding...''${RESET}"
      if ! sudo nixos-rebuild switch --flake ./nixos#TrudePC; then
        exit 1
      fi
      echo
      echo -e "''${ORANGE}Cleaning up old generations...''${RESET}"
      sudo nix-collect-garbage --delete-older-than 15d &> /dev/null
      popd > /dev/null
    '')
    (pkgs.writeShellScriptBin "update" ''
      set -e
      ORANGE='\e[38;5;214m'
      RESET='\e[0m'

      pushd ~/dotfiles > /dev/null
      echo -e "''${ORANGE}Updating Flake...''${RESET}"
      sudo nix flake update --flake ./nixos
      popd > /dev/null
      rebuild
    '')
  ];

  home.sessionVariables = {
    EDITOR = "gnome-text-editor";
  };

  home.file = {
    "Templates/markdown.md".text = "";
    "Templates/text.txt".text = "";
    ".config/vesktop/settings/settings.json" = {
      source = ../vencord/settings.json;
      force = true;
    };
    ".config/vesktop/themes/trude.theme.css" = {
      source = ../vencord/trude.theme.css;
      force = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "ehtrude@gmail.com";
        name = "TrudeEH";
        # signingKey will be provided by SSH agent (KeePassXC)
      };
      gpg.format = "ssh";
      gpg.ssh.defaultKeyCommand = "ssh-add -L";
      core.editor = "commit";
      commit.gpgSign = true;
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        # Use keys from SSH agent instead of identity files
        identitiesOnly = false;
      };
      server = {
        hostname = "192.168.0.2";
        user = "trude";
        port = 6022;
      };
      work = {
        hostname = "100.109.38.42"; # Tailscale IP
        user = "trude";
        port = 6022;
      };
    };
  };

  programs.keepassxc = {
    enable = true;
    settings = {
      Browser = {
        Enabled = true;
        UpdateBinaryPath = false; # Prevent conflicts with home-manager managed manifest
      };
      SSHAgent = {
        Enabled = true;
      };
      Security = {
        LockDatabaseIdle = false;
        LockDatabaseIdleSeconds = 0;
        LockDatabaseMinimize = false;
        LockDatabaseScreenLock = false;
      };
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      l = "ls -alh";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      ll = "ls -lhi";
      ta = "tmux attach";
      t = "tmux";
      v = "nvim";
      raid = "sudo mdadm --detail /dev/md0";
      unp = "unp -U";
      cat = "bat";
    };
    historySize = 10000;
    historyFileSize = 100000;
    initExtra = ''
      shopt -s histappend
      shopt -s checkwinsize
      shopt -s extglob
      set completion-ignore-case On
      export PS1="\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ "
    '';
    enableCompletion = true;
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = false;
    escapeTime = 250;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    aggressiveResize = true;
    extraConfig = ''
      set -g pane-base-index 1

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
      set-option -g status-right '#[fg=orange]S:#[default]#S %d#[fg=orange]/#[default]%m#[fg=orange]/#[default]%Y %I:%M#[fg=orange]%P#[default]'
      set -g status-interval 1
      set -g status-right-length 60

      set -g @cpu_high_fg_color "#[fg=#FF0000]"
      set -g @ram_high_fg_color "#[fg=#FF0000]"
    '';
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file://${config.home.homeDirectory}/dotfiles/wallpapers/bg.png";
        picture-uri-dark = "file://${config.home.homeDirectory}/dotfiles/wallpapers/dragon.png";
        primary-color = "#000000";
        secondary-color = "#000000";
      };
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [
          (lib.hm.gvariant.mkTuple [
            "xkb"
            "us+altgr-intl"
          ])
        ];
        xkb-options = [ "terminate:ctrl_alt_bksp" ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        cursor-size = 22;
        cursor-theme = "Adwaita";
        enable-hot-corners = false;
        font-name = "Adwaita Sans 11";
        gtk-theme = "Adwaita";
        document-font-name = "Adwaita Sans 11";
        icon-theme = "Adwaita";
        monospace-font-name = "JetBrainsMono NF 13";
        clock-format = "12h";
        accent-color = "teal";
        show-battery-percentage = true;
      };
      "org/gnome/desktop/screensaver" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file://${config.home.homeDirectory}/dotfiles/wallpapers/bg.png";
        primary-color = "#000000";
        secondary-color = "#000000";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = ":minimize,close";
        resize-with-right-button = true;
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = true;
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = [
          "tiling-assistant@ubuntu.com"
          "ubuntu-dock@ubuntu.com"
          "ding@rastersoft.com"
        ];
        enabled-extensions = [
          "blur-my-shell@aunetx"
          "gsconnect@andyholmes.github.io"
          "appindicatorsupport@rgcjonas.gmail.com"
          "caffeine@patapon.info"
          "Vitals@CoreCoding.com"
        ];
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        dash-max-icon-size = 32;
        dock-fixed = false;
        dock-position = "BOTTOM";
        extend-height = false;
      };
      "org/gnome/shell/extensions/ding" = {
        check-x11wayland = true;
        icon-size = "small";
        show-home = false;
      };
      "org/gnome/shell/world-clocks" = {
        locations = [ ];
      };
      "org/gnome/Console" = {
        use-system-font = false;
        custom-font = "JetBrainsMono Nerd Font 10";
      };
      "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        background-color = "rgb(29,29,29)";
        cell-width-scale = 1.0;
        font = "JetBrainsMono NF 10";
        foreground-color = "rgb(208,207,204)";
        palette = [
          "rgb(36,31,49)"
          "rgb(192,28,40)"
          "rgb(46,194,126)"
          "rgb(245,194,17)"
          "rgb(30,120,228)"
          "rgb(152,65,187)"
          "rgb(10,185,220)"
          "rgb(192,191,188)"
          "rgb(94,92,100)"
          "rgb(237,51,59)"
          "rgb(87,227,137)"
          "rgb(248,228,92)"
          "rgb(81,161,255)"
          "rgb(192,97,203)"
          "rgb(79,210,253)"
          "rgb(246,245,244)"
        ];
        use-system-font = false;
        use-theme-colors = false;
      };
      "org/gnome/Ptyxis" = {
        cursor-shape = "block";
        default-profile-uuid = "e2f22120c44e38d269767ed967d0430c";
        font-name = "JetBrainsMono Nerd Font 10";
        profile-uuids = [ "e2f22120c44e38d269767ed967d0430c" ];
        use-system-font = false;
      };
      "org/gnome/Ptyxis/Profiles/e2f22120c44e38d269767ed967d0430c" = {
        bold-is-bright = false;
        label = "Trude";
        palette = "Vs Code";
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        mic-mute = [ "<Super>F9" ];
        next = [ "<Super>F8" ];
        play = [ "<Super>F7" ];
        previous = [ "<Super>F6" ];
        volume-down = [ "<Super>F10" ];
        volume-mute = [ "<Super>F11" ];
        volume-up = [ "<Super>F12" ];
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-temperature = 2700;
      };
      "org/gnome/TextEditor" = {
        highlight-current-line = true;
        show-map = true;
      };
      "org/gnome/desktop/sound" = {
        event-sounds = true;
      };
      "org/gnome/epiphany" = {
        use-google-search-suggestions = true;
        default-search-engine = "Google";
      };
      "org/gnome/epiphany/web" = {
        show-developer-actions = true;
        remember-passwords = false;
      };
      "org/gnome/shell/extensions/vitals" = {
        fixed-widths = false;
        hot-sensors = [
          "_processor_usage_"
          "_gpu#1_usage_"
          "_memory_usage_"
          "_memory_swap_usage_"
          "__temperature_max__"
        ];
        icon-style = 1;
        menu-centered = false;
        position-in-panel = 0;
        show-battery = false;
        show-gpu = true;
        show-system = true;
        use-higher-precision = false;
      };
    };
  };

  xdg = {
    enable = true;
    mimeApps = {
      associations.added = {
        "text/x-shellscript" = [ "org.gnome.TextEditor.desktop" ];
      };
      defaultApplications = {
        "text/x-shellscript" = [ "org.gnome.TextEditor.desktop" ];
      };
    };
  };

  systemd.user.services.noisetorch = {
    Unit = {
      Description = "NoiseTorch Noise Cancelling";
      After = [
        "pipewire.service"
        "wireplumber.service"
      ];
      Wants = [
        "pipewire.service"
        "wireplumber.service"
      ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "30s";

      ExecStart = toString (
        pkgs.writeShellScript "start-noisetorch" ''
          set -eu

          # Give PipeWire/WirePlumber a moment to settle
          sleep 5

          source="$(${pkgs.pulseaudio}/bin/pactl get-default-source)"

          if [ -z "$source" ]; then
            echo "No default source found" >&2
            exit 1
          fi

          exec ${pkgs.noisetorch}/bin/noisetorch -i -s "$source"
        ''
      );

      ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
