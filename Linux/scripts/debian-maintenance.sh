#! /bin/bash

source ~/dotfiles/scripts/color.sh
source ~/dotfiles/scripts/p.sh

echo -e "${GREEN}[+] Updating...${ENDCOLOR}"
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
echo -e "${GREEN}[+] Cleaning...${ENDCOLOR}"
sudo apt autoremove
sudo apt autoclean

echo -e "${GREEN}[+] Removing logs older than 7d...${ENDCOLOR}"
sudo journalctl --vacuum-time=7d

if p c flatpak &>/dev/null; then
    echo -e "${GREEN}[+] Cleaning flatpak...:${ENDCOLOR}"
    flatpak remove --unused
fi
