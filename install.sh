#!/bin/bash

# -r : Only reload configurations

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

trap "echo -e '${RED}install.sh interrupted.${NC}'; exit 1" SIGINT SIGTERM

install_gnome_extension() {
   local uuid="$1"

   if [ -z "$uuid" ]; then
      printf "${RED}Usage: install_gnome_extension <extension-uuid>${NC}\n"
      return 1
   fi

   if ! gnome-extensions list | grep -qw "$uuid"; then
      printf "${GREEN}Sent install request for %s.${NC}\n" "$uuid"
      gdbus call --session --dest org.gnome.Shell.Extensions \
         --object-path /org/gnome/Shell/Extensions \
         --method org.gnome.Shell.Extensions.InstallRemoteExtension \
         "$uuid" >/dev/null 2>&1
      return 0
   elif gnome-extensions list --updates | grep -qw "$uuid"; then
      printf "${GREEN}Sent update request for %s.${NC}\n" "$uuid"
      gdbus call --session --dest org.gnome.Shell.Extensions \
         --object-path /org/gnome/Shell/Extensions \
         --method org.gnome.Shell.Extensions.InstallRemoteExtension \
         "$uuid" >/dev/null 2>&1
      return 0
   else
      printf "${GREEN}GNOME Extension %s is already installed.${NC}\n" "$uuid"
      return 0
   fi
}

# Flags
reload=false
for arg in "$@"; do
   if [ "$arg" = "-r" ]; then
      reload=true
      break
   fi
done

# Clone Dotfiles if not already present
cd "$HOME/dotfiles"
if [ "$(pwd)" != "$HOME/dotfiles" ]; then
   printf "${YELLOW}Cloning dotfiles repository...${NC}\n"
   sudo apt update
   sudo apt install -y git
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

mkdir -p "$HOME/dotfiles/logs"

printf "${CYAN}\n"
printf "####################\n"
printf "#"
printf "${PURPLE} Trude's Dotfiles${CYAN} #\n"
printf "####################\n"
fetch
printf "\n"

# Install Programs
if [ "$reload" = false ]; then
   sudo apt install curl git tmux fzf tldr pass lynis bat ufw
fi

# Copy files
printf "${YELLOW}Installing Dotfiles...${NC}\n"
cp -r "$HOME/dotfiles/home/." "$HOME"

# Copy scripts
printf "${YELLOW}Installing Scripts...${NC}\n"
mkdir -p "$HOME/.local/bin"
cp -r "$HOME/dotfiles/scripts/." "$HOME/.local/bin/"

# Install fonts
printf "${YELLOW}Installing fonts...${NC}\n"
mkdir -p "$HOME/.local/share/fonts"
cp -rf "$HOME/dotfiles/fonts/"* "$HOME/.local/share/fonts/"
fc-cache -fv "$HOME/.local/share/fonts" >"$HOME/dotfiles/logs/font_install.log"

# UFW Firewall
if [ "$reload" = false ]; then
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
fi

# Trude-only settings
if [ "$USER" = "trude" ]; then
   # Git config
   git config --global commit.gpgsign true
   git config --global tag.gpgSign true
   git config --global gpg.format ssh
   git config --global user.signingkey ~/.ssh/id_ed25519.pub
   git config --global user.name "TrudeEH"
   git config --global user.email "ehtrude@gmail.com"

   # Clone password-store
   if [ ! -f "$HOME/.ssh/id_ed25519" ] || [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
      printf "${RED}ED25519 key not found in ${CYAN}$HOME/.ssh/id_ed25519. ${RED}Please add your ED25519 key pair for password-store.${NC}\n"
   elif ! gpg --list-keys "ehtrude@gmail.com" >/dev/null 2>&1; then
      printf "${RED}GPG key for ehtrude@gmail.com not found. Please import the key for password-store.${NC}\n"
   else
      if [ ! -d "$HOME/.password-store" ]; then
         printf "${YELLOW}Cloning password-store...${NC}\n"
         chmod 700 ~/.ssh
         chmod 600 ~/.ssh/*
         git clone git@github.com:TrudeEH/password-store.git "$HOME/.password-store"
         if [ $? -ne 0 ]; then
            printf "${RED}Error cloning password-store.${NC}\n"
         else
            printf "${GREEN}Password-store cloned successfully.${NC}\n"
         fi
      else
         printf "${CYAN}Password-store already present.${NC}\n"
      fi
   fi
fi

# Security Scan
if [ "$reload" = false ] && [ ! -f "$HOME/dotfiles/logs/lynis_scan.log" ]; then
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

# Set up GNOME Desktop
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
   printf "${YELLOW}Installing GNOME Extensions...${NC}\n"
   install_gnome_extension "appindicatorsupport@rgcjonas.gmail.com"
   install_gnome_extension "caffeine@patapon.info"

   printf "${YELLOW}Loading Dconf settings...${NC}\n"
   dconf load / <"$HOME/dotfiles/dconf-settings.ini"
   if [ $? -ne 0 ]; then
      printf "${RED}Error loading Dconf settings.${NC}\n"
   else
      printf "${GREEN}Dconf settings loaded successfully.${NC}\n"
   fi
fi
