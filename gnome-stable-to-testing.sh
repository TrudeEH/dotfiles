#! /bin/bash

sudo cp -f ./debian-sources.list /etc/apt/sources.list

sudo apt update
sudo apt upgrade -y
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y
