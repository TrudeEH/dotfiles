#! /bin/bash

source ~/dotfiles/scripts/p.sh
source ~/dotfiles/scripts/color.sh

echo -e "${GREEN}[+] Updating...${ENDCOLOR}"
sudo paru -Syu

echo -e "${GREEN}[+] Cleaning orphaned (unneeded) packages...${ENDCOLOR}"
sudo paru -Rsn $(paru -Qdtq)

echo -e "${GREEN}[+] Cleaning old pacman cache...${ENDCOLOR}"
if p c pacman-contrib &>/dev/null; then
    paccache -rk1
else
    p i pacman-contrib
    paccache -rk1
fi

echo -e "${GREEN}[+] Removing logs older than 7d...${ENDCOLOR}"
sudo journalctl --vacuum-time=7d

if p c flatpak &>/dev/null; then
    echo -e "${GREEN}[+] Cleaning flatpak...:${ENDCOLOR}"
    flatpak remove --unused
fi

echo -e "${GREEN}[i] AUR Packages installed:${ENDCOLOR}"
pacman -Qim | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h

# Installed packages: pacman -Qen
