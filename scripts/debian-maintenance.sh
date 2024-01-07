#! /bin/bash

source ~/dotfiles/scripts/color.sh
source ~/dotfiles/scripts/p.sh

echo -e "${GREEN}[+] Upgrading...${ENDCOLOR}"
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo apt autoremove
sudo apt autoclean

echo -e "${GREEN}[+] Removing logs older than 7d...${ENDCOLOR}"
sudo journalctl --vacuum-time=7d

if p c flatpak &>/dev/null; then
    echo -e "${GREEN}[+] Cleaning flatpak...:${ENDCOLOR}"
    flatpak remove --unused
fi

read -p "Press enter to exit."
