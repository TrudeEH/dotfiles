#! /bin/bash

compile() {
  cd programs/$1
  sudo make clean install
  cd ../..
}

# Install Dependencies
sudo apt install -y xorg picom libx11-dev libxft-dev libxinerama-dev build-essential libxrandr-dev policykit-1-gnome dbus-x11 pipewire-audio wireplumber pipewire-pulse pipewire-alsa network-manager firefox-esr feh scrot dunst
systemctl --user --now enable wireplumber.service
sudo systemctl enable NetworkManager

# Compile
for program in "dwm" "dmenu" "slock" "st" "tabbed" "dwmblocks"; do
  compile $program
done
