#! /bin/bash

# Update base OS and install programs
sudo apt install nala -y
sudo nala update
sudo nala upgrade

sudo nala install htop fzf tmux git stow vim wget

# Clone repo if needed
if [ $(pwd) != "$HOME/cros" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/cros --depth=1
    cd cros
fi

# Install Github CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

# Link dotfiles
stow -v -t $HOME dotfiles --adopt
git diff
git reset --hard

# Fonts
fc-cache -fv

# Desktop
sudo nala install gnome-core
sudo rm -rf /etc/network/interfaces #Fix Wifi settings bug

dconf load / < settings.dconf

# Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo nala install ./google-chrome-stable_current_amd64.deb
rm ./google-chrome-stable_current_amd64.deb
