#! /bin/sh

echo "Updating user packages..."
doas pkg update
doas pkg upgrade
