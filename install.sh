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
echo "Updating packages..."
kgx -e "sudo pacman -Syu && sudo pacman -S git"
read -p "Press enter to continue."

# Mirrors
if ask "Choose best mirrors (LONG TIME)?"; then
    kgx -e "sudo pacman -S reflector && sudo reflector --sort rate -p https --save /etc/pacman.d/mirrorlist --verbose"
    read -p "Press enter to continue."
fi

# Install paru
paru=$(pacman -Q paru)
if [[ -n "$paru" ]]; then
    echo -e "\e[32m[I] Paru is already installed.\e[0m"
else
    kgx -e "sudo pacman -S --needed base-devel && \
    git clone https://aur.archlinux.org/paru.git && \
    cd paru && \
    makepkg -si && \
    cd .. && \
    rm -rf paru"
fi
read -p "Press enter to continue."

# Enable bluetooth support
if ask "Enable bluetooth?"; then
    kgx -e "sudo pacman -S bluez bluez-utils && \
    sudo systemctl start bluetooth.service; \
    sudo systemctl enable bluetooth.service"
fi

# Enable printer support
if ask "Enable CUPS (printer)?"; then
    kgx -e "sudo pacman -S cups && \
    sudo systemctl start cups; \
    sudo systemctl start cups.service; \
    sudo systemctl enable cups; \
    sudo systemctl enable cups.service"
fi

# Install Tela Icons
echo "Installing Tela Icon Theme..."
kgx -e "git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git && \
cd Tela-circle-icon-theme && \
./install.sh ; \
cd .. && \
rm -rf Tela-circle-icon-theme; \
gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle'"
read -p "Press enter to continue."

# Install Cursor theme
echo "Installing Cursor Theme..."
kgx -e "paru -S bibata-cursor-theme-bin && gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'"
read -p "Press enter to continue."

# Install Nerd Font
echo "Installing JetBrains font..."
kgx -e "sudo pacman -S ttf-jetbrains-mono-nerd"
read -p "Press enter to continue."

# Enable minimize button
echo "Enabling minimize button..."
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,close"

# Enable flatpak support
if ask "Enable flatpak?"; then
    kgx -e "sudo pacman -S flatpak && \
    flatpak install flatseal; \
    sudo flatpak override --filesystem=$HOME/.themes; \
    sudo flatpak override --filesystem=$HOME/.icons"
fi
