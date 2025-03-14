#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

mkdir -p "$HOME/dotfiles/logs"

# Clone Dotfiles if not already present
cd "$HOME/dotfiles"
if [ "$(pwd)" != "$HOME/dotfiles" ]; then
   printf "${YELLOW}Cloning dotfiles repository...${NC}\n"
   git clone https://github.com/TrudeEH/dotfiles --depth 1
   if [ $? -ne 0 ]; then
      printf "${RED}Error cloning dotfiles repository. Exiting...${NC}\n"
      exit 2
   fi
   cd dotfiles || exit
   printf "${GREEN}dotfiles repository cloned successfully.${NC}\n"
else
   printf "${YELLOW}Updating dotfiles repository...${NC}\n"
   pull_output=$(git pull)
   printf "%s\n" "$pull_output"
   if ! echo "$pull_output" | grep -q "Already up to date."; then
      printf "${YELLOW}Changes detected. Re-running script...${NC}\n"
      exec "$0" "$@"
   fi
fi

source ./scripts/p.sh

printf "${CYAN}\n"
printf "####################\n"
printf "#"
printf "${PURPLE} Trude's Dotfiles${CYAN} #\n"
printf "####################\n"
printf "${CYAN}Running on: ${PURPLE}%s${NC}\n" "$OSTYPE"
printf "\n"

# Install Programs
programs=(neovim curl git tmux htop fzf gcc make tldr pass lynis)

if [[ "$OSTYPE" != "darwin"* ]]; then
   programs+=(ufw s-tui)
fi

p i "${programs[@]}"

# Copy files
printf "${YELLOW}Installing Dotfiles...${NC}\n"
cp -r "$HOME/dotfiles/home/." "$HOME"
if [ $? -ne 0 ]; then
   printf "${RED}Error copying Dotfiles.${NC}\n"
else
   printf "${GREEN}Dotfiles installed successfully.${NC}\n"
fi

# Copy scripts
printf "${YELLOW}Installing Scripts...${NC}\n"
mkdir -p "$HOME/.local/bin"
cp -r "$HOME/dotfiles/scripts/." "$HOME/.local/bin/"
if [ $? -ne 0 ]; then
   printf "${RED}Error copying Scripts.${NC}\n"
else
   printf "${GREEN}Scripts installed successfully.${NC}\n"
fi

# Install fonts
printf "${YELLOW}Installing fonts...${NC}\n"
if [[ "$OSTYPE" == "darwin"* ]]; then
   cp -rf "$HOME/dotfiles/fonts/"* "$HOME/Library/Fonts/"
   if [ $? -ne 0 ]; then
      printf "${RED}Error installing fonts.${NC}\n"
   else
      printf "${GREEN}Fonts installed successfully.${NC}\n"
   fi
else
   mkdir -p "$HOME/.local/share/fonts"
   cp -rf "$HOME/dotfiles/fonts/"* "$HOME/.local/share/fonts/"
   if [ $? -ne 0 ]; then
      printf "${RED}Error installing fonts.${NC}\n"
   else
      fc-cache -fv "$HOME/.local/share/fonts" >"$HOME/dotfiles/logs/font_install.log"
      printf "${GREEN}Fonts installed successfully.${NC}\n"
   fi
fi

# Load Dconf (GNOME settings)
if [[ "$OSTYPE" != "darwin"* ]]; then
   printf "${YELLOW}Loading Dconf settings...${NC}\n"
   dconf load / <"$HOME/dotfiles/dconf-settings.ini"
   if [ $? -ne 0 ]; then
      printf "${RED}Error loading Dconf settings.${NC}\n"
   else
      printf "${GREEN}Dconf settings loaded successfully.${NC}\n"
   fi
fi

# UFW Firewall
if [[ "$OSTYPE" != "darwin"* ]]; then
   printf "${YELLOW}Setting up UFW...${NC}\n"
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   if systemctl is-active --quiet sshd; then
      printf "${YELLOW}SSH Server detected; Enabling SSH rule...${NC}\n"
      sudo ufw limit 22/tcp
   fi
   sudo ufw enable
   sudo ss -tupln | tee "$HOME/dotfiles/logs/open_ports.log"
   sudo ufw status numbered | tee "$HOME/dotfiles/logs/ufw_status.log"
   if [ $? -ne 0 ]; then
      printf "${RED}Error setting up UFW.${NC}\n"
   else
      printf "${GREEN}UFW setup successfully.${NC}\n"
   fi
else
   printf "${YELLOW}Enabling macOS Firewall...${NC}\n"
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
   if [ $? -ne 0 ]; then
      printf "${RED}Error enabling Firewall.${NC}\n"
   else
      printf "${GREEN}Firewall enabled successfully.${NC}\n"
   fi
fi

# Clone password-store
if [ "$(whoami)" = "trude" ]; then
   if [ ! -d "$HOME/.password-store" ]; then
      printf "${YELLOW}Cloning password-store...${NC}\n"
      git clone https://github.com/TrudeEH/password-store "$HOME/.password-store"
      if [ $? -ne 0 ]; then
         printf "${RED}Error cloning password-store.${NC}\n"
      else
         printf "${GREEN}Password-store cloned successfully.${NC}\n"
      fi
   else
      printf "${CYAN}Password-store already present.${NC}\n"
   fi
fi

# Security Scan
if [ ! -f "$HOME/dotfiles/logs/lynis_scan.log" ]; then
   printf "${YELLOW}Running Lynis Security Scan...${NC}\n"
   sudo lynis audit system | tee "$HOME/dotfiles/logs/lynis_scan.log"
   if [ $? -ne 0 ]; then
      printf "${RED}Error running Lynis.${NC}\n"
   else
      printf "${GREEN}Lynis scan completed.${NC}\n"
   fi
else
   printf "${CYAN}Previous Lynis scan detected, read the log @ $HOME/dotfiles/logs/lynis_scan.log.${NC}\n"
fi
