#! /bin/bash
echo "Add \"contrib non-free\" to the end of each repo. Press ENTER to edit /etc/apt/sources.list."
read
sudoedit /etc/apt/sources.list

sudo dpkg --add-architecture i386
sudo nala update
sudo nala install steam

