#!/bin/bash
# Script to install Arch Linux from the liveCD.

echo "[+] Installing dependencies..."
pacman -Sy --noconfirm curl reflector archlinux-keyring

echo "[+] Selecting the fastest mirrors..."
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

archinstall
