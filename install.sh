#! /bin/bash

source scripts/p.sh
source scripts/color.sh

# ============== CONFIG ==============

# Install Dependency: stow
p i stow

# Link dotfile home to $HOME
echo -e "${GREEN}[+] Symlinking dotfiles...${ENDCOLOR}"
stow -v -t $HOME home --adopt
