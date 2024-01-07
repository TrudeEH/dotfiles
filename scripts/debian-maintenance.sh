#! /bin/bash
echo -e "\e[31m[+] Upgrading...\e[0m"
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo apt autoremove
sudo apt autoclean

echo -e "\e[31m[+] Removing logs older than 7d...\e[0m"
sudo journalctl --vacuum-time=7d

echo -e "\e[31m[i] Cleaning flatpak...:\e[0m"
flatpak remove --unused

read -p "Press enter to exit."
