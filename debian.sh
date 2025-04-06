#! /bin/bash

./scripts/update
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bckp
sudo cp debian-sources.list /etc/apt/sources.list
./scripts/update

sudo apt install gnome-core flatpak gnome-software-plugin-flatpak epiphany-browser
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Enable Network Manager
sudo mv /etc/network/interfaces /etc/network/interfaces.bckp
sudo systemctl restart networking
sudo service NetworkManager restart

# Remove Firefox (Epiphany installed instead)
sudo apt purge firefox-esr
