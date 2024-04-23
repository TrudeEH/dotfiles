#! /bin/bash

if [ ! $(command -v paru) ]; then
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
fi

# Install script dependencies
paru -Sy curl git stow bat fzf eza zoxide less

paru -Sy vscodium-bin

if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles
    cd dotfiles
fi

echo -e "${GREEN}[+] Symlinking dotfiles...${ENDCOLOR}"
stow -v -t $HOME dotfiles --adopt
git diff
git reset --hard

dconf reset -f /
dconf load / < dconf-settings

xdg-settings set default-web-browser org.gnome.Epiphany.desktop

echo
echo -e "${GREEN}[I] Done. Rebooting in 5 seconds...${ENDCOLOR}"
sleep 5

systemctl reboot
reboot
