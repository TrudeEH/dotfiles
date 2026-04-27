# man home-configuration.nix
{
  pkgs,
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

    easyeffects
    brave
    nextcloud-client
    qbittorrent
    trude.universalStickers
    vencord
    onlyoffice-desktopeditors
    planify
    # Stremio
    (pkgs.stremio-linux-shell.overrideAttrs (old: rec {
      postPatch = ''
        substituteInPlace src/config.rs \
          --replace-fail "@serverjs@" "${placeholder "out"}/share/stremio/server.js"

        for f in \
          "$cargoDepsCopy"/libappindicator-sys-*/src/lib.rs \
          "$cargoDepsCopy"/xkbcommon-dl-*/src/lib.rs \
          "$cargoDepsCopy"/xkbcommon-dl-*/src/x11.rs; do
          if [ -e "$f" ]; then
            case "$f" in
              *libappindicator-sys-*/src/lib.rs)
                substituteInPlace "$f" \
                  --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
                ;;
              *xkbcommon-dl-*/src/lib.rs)
                substituteInPlace "$f" \
                  --replace-fail "libxkbcommon.so.0" "${libxkbcommon}/lib/libxkbcommon.so.0"
                ;;
              *xkbcommon-dl-*/src/x11.rs)
                substituteInPlace "$f" \
                  --replace-fail "libxkbcommon-x11.so.0" "${libxkbcommon}/lib/libxkbcommon-x11.so.0"
                ;;
            esac
          fi
        done
      '';
    }))
    element-desktop

    # Dev tools
    vscode
    nodejs
    python3

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
      ORANGE='\e[38;5;214m'
      RESET='\e[0m'
      host_name="$(hostnamectl --static 2>/dev/null || hostname)"

      pushd ~/dotfiles > /dev/null
      git diff -U0 *.nix
      echo -e "''${ORANGE}NixOS Rebuilding ''${host_name}...''${RESET}"
      if ! sudo nixos-rebuild switch --flake "./nixos#''${host_name}"; then
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

  home.file = {
    ".config/vesktop/settings/settings.json" = {
      source = ../vencord/settings.json;
      force = true;
    };
    ".config/vesktop/themes/trude.theme.css" = {
      source = ../vencord/trude.theme.css;
      force = true;
    };
    ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "ehtrude@gmail.com";
        name = "TrudeEH";
        # Public key corresponding to the SSH key exposed through the agent.
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHbrKen3nEQGRJidjGwLUDCo+dLGaKIaLzS/RTZDjPZ trude";
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
        LockDatabaseIdleSeconds = 300;
        LockDatabaseMinimize = false;
        LockDatabaseScreenLock = true;
      };
    };
  };

  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    installBatSyntax = true;
    settings = {
      theme = "Adventure";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      term = "ghostty";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      l = "ls -alh";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      ll = "ls -lhi";
      la = "ls -A";
      lt = "ls --tree";
      ta = "tmux attach";
      t = "tmux";
      v = "nvim";
      raid = "sudo mdadm --detail /dev/md0";
      unp = "unp -U";
      cat = "bat";
      df = "df -h";
      du = "du -h";
      free = "free -h";
      ip = "ip -color=auto";
      diff = "diff --color=auto";
      mkdir = "mkdir -pv";
    };

    historySize = 50000;
    historyFileSize = 200000;

    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    historyIgnore = [
      "ls"
      "ll"
      "la"
      "l"
      "cd"
      "pwd"
      "exit"
      "clear"
      "history"
    ];

    # Prefer this over repeating shopt lines manually.
    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "cdspell"
      "dirspell"
      "autocd"
      "cmdhist"
      "checkjobs"
      "no_empty_cmd_completion"
    ];

    # Useful in many terminal emulators so cwd tracking works properly.
    enableVteIntegration = true;

    initExtra = ''
      # Readline / completion niceties
      bind 'set show-all-if-ambiguous on'
      bind 'set completion-ignore-case on'
      bind 'set completion-map-case on'
      bind 'set mark-symlinked-directories on'
      bind 'TAB:menu-complete'
      bind '"\e[Z": menu-complete-backward'

      # Better history search with arrow keys
      bind '"\e[A": history-search-backward'
      bind '"\e[B": history-search-forward'

      # Append and reload history across multiple shells
      PROMPT_COMMAND='history -a; history -n; '"$PROMPT_COMMAND"

      # Less behavior
      export LESS='-FRiMX'
      export MANPAGER='less -R'

      # Prefer bat for paging if present
      export BAT_PAGER="less -FR"

      # Prompt with exit code on failure and job count
      __bash_prompt() {
        local ec=$?
        local reset='\[\e[0m\]'
        local bold='\[\e[1m\]'
        local dim='\[\e[2m\]'
        local white='\[\e[37m\]'
        local red='\[\e[31m\]'
        local blue='\[\e[34m\]'

        local status=""
        if [ "$ec" -ne 0 ]; then
          status=" ''${red}x:$ec''${reset}"
        fi

        PS1="\n[''${white}\u''${reset}@''${dim}\h''${reset}] ''${bold}''${blue}\w''${reset}''${status} ''${dim}J:''${reset}\j\n\\$ "
      }
      PROMPT_COMMAND="__bash_prompt; $PROMPT_COMMAND"
    '';
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

  xdg = {
    enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
