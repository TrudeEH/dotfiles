#! /bin/bash

# Ask Y/n
function ask() {
    read -p "$1 (Y/n): " resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
    fi

    [ "$response_lc" = "y" ]
}

# Upgrade
sudo pacman -Syu
sudo pacman -S git

# Enable bluetooth support
if ask "Enable bluetooth?"; then
    sudo pacman -S bluez bluez-utils
    sudo systemctl start bluetooth.service
    sudo systemctl enable bluetooth.service
fi

# Enable printer support
if ask "Enable CUPS (printer)?"; then
    sudo pacman -S cups
    sudo systemctl start cups
    sudo systemctl start cups.service
    sudo systemctl enable cups
    sudo systemctl enable cups.service
fi

# Install Tela Icons
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme
./install.sh
cd ..
rm -rf Tela-circle-icon-theme
gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle'

# Install Nerd Font
sudo pacman -S ttf-jetbrains-mono-nerd

# Enable minimize button
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,close"

# Enable flatpak support
if ask "Enable flatpak?"; then
    sudo pacman -S flatpak
    flatpak install flatseal

    # Fix theme for flatpak
    sudo flatpak override --filesystem=$HOME/.themes
    sudo flatpak override --filesystem=$HOME/.icons
fi
