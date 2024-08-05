#! /bin/bash

if ! command -v zenity; then
  sudo apt-get install zenity -y
fi

# Update System
(
sudo apt-get update
echo "20"
echo "# Updating distro packages..."
sudo apt-get dist-upgrade -y
echo "40"
echo "# Updating installed packages..."
sudo apt-get upgrade -y
echo "60"
echo "# Cleaning cache..."
sudo apt-get clean
echo "80"
echo "# Removing unused dependencies..."
sudo apt-get autoremove -y
echo "100"
) |
zenity --progress --title="Update System" --text="Updating repositories..." --percentage=0 --no-cancel

# Dotfiles
zenity --question \
--title="Dotfiles" \
--text="Apply Trude's configuration files?"

if [[ $? == 0 ]]; then
    (
    sudo apt-get install -y htop fzf git wget curl bash-completion
    echo "20"
    echo "# Copying dotfiles..."
    cp -vrf config-files/.* $HOME
    echo "40"
    cp -vrf config-files/* $HOME
    echo "50"
    echo "# Configure GNOME/GTK..."
    dconf load -f / < ./settings.dconf
    echo "60"
    echo "# Reloading font cache..."
    fc-cache -f
    echo "100"
    ) |
    zenity --progress --title="Configuration" --text="Installing common utilities..." --percentage=0 --no-cancel
fi

# Flatpak
zenity --question \
--title="Install Apps" \
--text="Enable Flatpak support?"

if [[ $? == 0 ]]; then
    (
    sudo apt install -y flatpak
    echo "30"
    echo "# Install the gnome-software plugin..."
    sudo apt install -y gnome-software-plugin-flatpak
    echo "50"
    echo "# Add Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo "75"
    echo "# Installing Adw GTK3 theme for flatpak apps..."
    flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    echo "100"
    ) |
    zenity --progress --title="Enabling Flatpak" --text="Installing Flatpak..." --percentage=0 --no-cancel
fi

# Apps
options=(
  FALSE "Install Neovim"
  FALSE "Install Zed"
  FALSE "Install Ollama"
  FALSE "Install GitHub CLI"
  FALSE "Install Tailscale (VPN)"
  FALSE "Install Syncthing"
)
checkbox=$(zenity --list --checklist \
  --title="Install Apps" \
  --column="Select" \
  --column="Tasks" "${options[@]}")
readarray -td '|' choices < <(printf '%s' "$checkbox")

for selection in "${choices[@]}"; do
  if [ "$selection" = "Install Neovim" ]; then
    (
    sudo apt install -y ninja-build gettext cmake unzip curl build-essential
    echo "30"
    git clone https://github.com/neovim/neovim --depth 1
    echo "50"
    cd neovim
    git checkout stable
    echo "60"
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    echo "80"
    sudo make install
    cd ..
    rm -rf neovim
    echo "100"
    ) |
    zenity --progress --title="Neovim" --text="Installing Neovim..." --percentage=0 --no-cancel
  fi

  if [ "$selection" = "Install Zed" ]; then
    zenity --notification --window-icon="info" --text="Installing Zed..."
    curl https://zed.dev/install.sh | sh
    if [[ $? == 0 ]]; then
        zenity --notification --window-icon="info" --text="Zed is now installed."
    else
        zenity --notification --window-icon="error" --text="Zed failed to install."
    fi
  fi

  if [ "$selection" = "Install Ollama" ]; then
    zenity --notification --window-icon="info" --text="Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    if [[ $? == 0 ]]; then
        zenity --notification --window-icon="info" --text="Ollama is now installed."
    else
        zenity --notification --window-icon="error" --text="Ollama failed to install."
    fi
  fi

  # ------ TODO ---------

  if [ "$selection" = "########" ]; then
    # Firefox Theme
    dialog --erase-on-exit \
           --backtitle "$BACKTITLE" \
           --title "Install the Adwaita Firefox theme?" \
           --yesno "OPEN FIREFOX BEFORE INSTALLING! The theme mimics GNOME Web and will be installed using the script provided by the theme on GitHub." 10 40

    if [ "$?" -eq 0 ]; then
      curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
    fi
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

  if [ "$selection" = "Install Apps (Enables Flatpak)" ]; then
    clear
    echo "----------------------------"
    echo "--- Install Applications ---"
    echo "----------------------------"
    echo
    echo



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
