#! /bin/bash

sudo pacman -Syu gnome power-profiles-daemon fwupd gst-plugin-pipewire

sudo systemctl enable power-profiles-daemon
sudo systemctl start power-profiles-daemon
