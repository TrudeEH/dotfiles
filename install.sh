#! /bin/bash

# Install Paru
if [ ! $(command -v paru) ]; then
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
fi

# Install script dependencies
paru -Sy curl git stow bat fzf less nextcloud-client

# Install Apps
paru -Sy obsidian signal-desktop fragments secrets newsflash eyedropper obfuscate gnome-console gnome-calendar impression gnome-podcasts geary brave-bin

# Install CLI Apps
paru -Sy iamb tmux ollama vim

if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles --depth=1
    cd dotfiles
fi

echo -e "${GREEN}[+] Symlinking dotfiles...${ENDCOLOR}"
stow -v -t $HOME dotfiles --adopt
git diff
git reset --hard

# dconf reset -f /
dconf load / < dconf-settings

xdg-settings set default-web-browser brave-browser.desktop

echo
echo -e "${GREEN}[I] Done.${ENDCOLOR}"
