#! /bin/bash

if ! command -v zenity; then
  sudo apt-get install zenity dialog -y
fi

BACKTITLE="Trude's Linux Toolkit"

options=(
  TRUE "Update OS"
  TRUE "Copy Dotfiles"
  FALSE "Install DWM Desktop"
  TRUE "Configure GNOME"
  TRUE "Install GitHub CLI"
  FALSE "Install Ollama"
  TRUE "Install Apps (Enables Flatpak)"
  FALSE "Install Tailscale (VPN)"
  FALSE "Install Syncthing"
)
# Use zenity --list to display menu and capture chosen option
checkbox=$(zenity --list --checklist \
  --title="$BACKTITLE" \
  --column="Select" \
  --column="Tasks" "${options[@]}")

readarray -td '|' choices < <(printf '%s' "$checkbox")

compile() {
  cd programs/$1
  sudo make clean install
  cd ../..
}

for selection in "${choices[@]}"; do
  if [ "$selection" = "Update OS" ]; then
    dialogUpdate() {
      dialog --backtitle "$BACKTITLE" --title "Update Debian and Packages" \
	       --mixedgauge "Updating..." \
	       0 0 $1 \
         "Update repos" "$2" \
         "Update distro" "$3" \
         "Update packages" "$4" \
         "Clean up " "$5"
    }

    dialogUpdate 0 7 4 4 4

    sudo apt-get update &> /dev/null
    dialogUpdate 15 5 7 4 4

    sudo apt-get dist-upgrade -y &> /dev/null
    dialogUpdate 35 5 5 7 4DWM

    sudo apt-get upgrade -y &> /dev/null
    dialogUpdate 80 5 5 5 7

    sudo apt-get clean &> /dev/null
    sudo apt-get autoremove -y &> /dev/null
    dialogUpdate 100 5 5 5 5
  fi

  if [ "$selection" = "Copy Dotfiles" ]; then
    # Neovim
    dialog --erase-on-exit \
           --backtitle "$BACKTITLE" \
           --title "Install/Update Neovim?" \
           --yesno "Nvim will be compiled from source. This may take a long time, depending on your device." 10 40

    if [ "$?" -eq 0 ]; then
      # NVIM has to be compiled from source to support arm64 and i386 devices, for example.
      sudo apt install -y ninja-build gettext cmake unzip curl build-essential
      git clone https://github.com/neovim/neovim --depth 1
      cd neovim
      git checkout stable
      make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
      cd ..
      rm -rf neovim
    fi

    # Zed
    #dialog --erase-on-exit \
    #       --backtitle "$BACKTITLE" \
    #       --title "Install Zed?" \
    #       --yesno "Zed (code editor) will be installed using the official install script." 10 40

    #if [ "$?" -eq 0 ]; then
    #  curl https://zed.dev/install.sh | sh
    #fi

    # Firefox Theme
    dialog --erase-on-exit \
           --backtitle "$BACKTITLE" \
           --title "Install the Adwaita Firefox theme?" \
           --yesno "OPEN FIREFOX BEFORE INSTALLING! The theme mimics GNOME Web and will be installed using the script provided by the theme on GitHub." 10 40

    if [ "$?" -eq 0 ]; then
      curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
    fi

    echo "Installing utilities..."
    sudo apt install -y htop fzf git wget curl bash-completion

    echo "Copying dotfiles..."
    cp -vrf dotfiles/.* $HOME
    cp -vrf dotfiles/* $HOME

    echo "Loading fonts..."
    fc-cache -f
  fi

  if [ "$selection" = "Install DWM Desktop" ]; then
    clear
    echo "---------------------------"
    echo "--- Install DWM Desktop ---"
    echo "---------------------------"
    echo
    echo

    # Install Dependencies
    sudo apt install -y xorg picom libx11-dev libxft-dev libxinerama-dev build-essential libxrandr-dev policykit-1-gnome dbus-x11 pipewire-audio wireplumber pipewire-pulse pipewire-alsa network-manager firefox-esr feh scrot dunst
    systemctl --user --now enable wireplumber.service
    sudo systemctl enable NetworkManager

    # Compile
    for program in "dwm" "dmenu" "slock" "st" "tabbed" "dwmblocks"; do
      compile $program
    done
  fi

  if [ "$selection" = "Configure GNOME" ]; then
    clear
    echo "-----------------------"
    echo "--- Configure GNOME ---"
    echo "-----------------------"
    echo
    echo

    dconf load -f / < ./settings.dconf
  fi

  if [ "$selection" = "Install GitHub CLI" ]; then
    clear
    echo "----------------------"
    echo "--- Install GH CLI ---"
    echo "----------------------"
    echo
    echo

    sudo apt install wget -y
    sudo mkdir -p -m 755 /etc/apt/keyrings
    sudo rm -f /etc/apt/sources.list.d/github-cli.list
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt update
    sudo apt install gh -y
  fi

  if [ "$selection" = "Install Ollama" ]; then
    clear
    echo "----------------------"
    echo "--- Install Ollama ---"
    echo "----------------------"
    echo
    echo

    # Ollama - LLM Server
    curl -fsSL https://ollama.com/install.sh | sh
  fi

  if [ "$selection" = "Install Apps (Enables Flatpak)" ]; then
    clear
    echo "----------------------------"
    echo "--- Install Applications ---"
    echo "----------------------------"
    echo
    echo

    echo "Enabling Flatpak..."
    sudo apt install -y flatpak
    sudo apt install -y gnome-software-plugin-flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    echo "Installing Flatpak GTK3 theme..."
    flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark

    dialog --erase-on-exit \
           --backtitle "$BACKTITLE" \
           --checklist "Select Apps to install." 30 90 5 \
            "io.github.mrvladus.List" "Errands (Tasks)" "on"\
            "io.gitlab.news_flash.NewsFlash" "Newsflash (RSS)" "on"\
            "org.gnome.gitlab.somas.Apostrophe" "Apostrophe (Markdown Editor)" "on"\
            "org.gnome.World.Secrets" "Secrets (Password manager)" "on"\
            "org.gnome.Polari" "Polari (IRC)" "off" \
            "org.gnome.Fractal" "Fractal (Matrix)" "on"\
            "so.libdb.dissent" "Dissent (Discord)" "on"\
            "io.gitlab.adhami3310.Impression" "Impression (Disk image creator)" "on"\
            "org.gnome.Builder" "Builder (IDE)" "on"\
            "org.gnome.design.AppIconPreview" "App Icon Preview" "on"\
            "org.gnome.design.IconLibrary" "Icon Library" "on"\
            "org.gnome.design.Palette" "Color Palette" "on"\
            "org.gnome.design.SymbolicPreview" "Symbolic Preview" "on"\
            "org.gnome.design.Typography" "Typography" "on"\
            "re.sonny.Workbench" "Workbench" "on"\
            "org.prismlauncher.PrismLauncher" "Prism Launcher" "off" 2> choice.tmp
    app_menu=$( cat choice.tmp )
    rm choice.tmp

    for app in $app_menu; do
      echo "Installing $app..."
      flatpak install -y flathub $app
    done
  fi

  if [ "$selection" = "Install Tailscale (VPN)" ]; then
    clear
    echo "-------------------------"
    echo "--- Install Tailscale ---"
    echo "-------------------------"
    echo
    echo

    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up
  fi

  if [ "$selection" = "Install Syncthing" ]; then
    clear
    echo "-------------------------"
    echo "--- Install Syncthing ---"
    echo "-------------------------"
    echo
    echo

    sudo apt install syncthing
    systemctl --user enable syncthing.service
    systemctl --user start syncthing.service
    xdg-open "http://127.0.0.1:8384/" &
  fi
done
