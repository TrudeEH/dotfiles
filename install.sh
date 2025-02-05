#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo
echo "####################"
echo "# Trude's Dotfiles #"
echo "####################"
echo

echo -e "${YELLOW}[+] Updating distro...${NC}"
sudo apt update

# Check if git is installed
if ! git --version &>/dev/null; then
   echo -e "${YELLOW}[+] Installing GIT...${NC}"
   sudo apt install -y git
   if [ $? -ne 0 ]; then
      echo -e "${RED}[E] Error installing GIT. Exiting...${NC}"
      exit 1
   fi
else
   echo -e "${GREEN}[I] GIT is already installed.${NC}"
fi

# Clone Dotfiles if not already present
cd $HOME/dotfiles
if [ $(pwd) != "$HOME/dotfiles" ]; then
   echo -e "${YELLOW}[+] Cloning Dotfiles repository...${NC}"
   git clone https://github.com/TrudeEH/dotfiles --depth 1
   if [ $? -ne 0 ]; then
      echo -e "${RED}[E] Error cloning Dotfiles repository. Exiting...${NC}"
      exit 2
   fi
   cd dotfiles
   echo -e "${GREEN}[I] Dotfiles repository cloned successfully.${NC}"
else
   echo -e "${GREEN}[I] Dotfiles repository already present.${NC}"
fi

# Copy files
echo -e "${YELLOW}[+] Installing Dotfiles...${NC}"
cp -r $HOME/dotfiles/home/. $HOME
if [ $? -ne 0 ]; then
   echo -e "${RED}[E] Error copying Dotfiles.${NC}"
else
   echo -e "${GREEN}[I] Dotfiles installed successfully.${NC}"
fi

# Load Dconf (GNOME settings)
echo -e "${YELLOW}[+] Loading Dconf settings...${NC}"
dconf load / <$HOME/dotfiles/dconf-settings.ini
if [ $? -ne 0 ]; then
   echo -e "${RED}[E] Error loading Dconf settings.${NC}"
else
   echo -e "${GREEN}[I] Dconf settings loaded successfully.${NC}"
fi
