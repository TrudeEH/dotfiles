#! /bin/bash

echo -e "\e[31m[+] Upgrading...\e[0m"
sudo paru -Syu

echo -e "\e[31m[+] Cleaning orphaned (unneeded) packages...\e[0m"
sudo paru -Rsn $(paru -Qdtq)

echo -e "\e[31m[+] Cleaning old pacman cache...\e[0m"
paccache -rk1

echo -e "\e[31m[+] Removing logs older than 7d...\e[0m"
sudo journalctl --vacuum-time=7d

echo -e "\e[31m[I] Cleaning flatpak...:\e[0m"
flatpak remove --unused

echo -e "\e[31m[I] AUR Packages installed:\e[0m"
pacman -Qim | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h

# Installed packages: pacman -Qen

read -p "Press enter to exit."
