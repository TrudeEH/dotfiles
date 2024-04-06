#! /bin/bash

sudo pacman -Syu gnome power-profiles-daemon

sudo systemctl enable power-profiles-daemon
sudo systemctl start power-profiles-daemon
