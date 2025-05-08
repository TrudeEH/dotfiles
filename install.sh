#! /bin/sh

# -r : Only reload configurations

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

trap 'printf "${RED}install.sh interrupted.${NC}"; exit 1' INT TERM

install_gnome_extension() {
   uuid="$1"

   if [ -z "$uuid" ]; then
      echo "${RED}Usage: install_gnome_extension <extension-uuid>${NC}"
      return 1
   fi

   if ! gnome-extensions list | grep -qw "$uuid"; then
      echo "${GREEN}Sent install request for $uuid.${NC}"
      gdbus call --session --dest org.gnome.Shell.Extensions \
         --object-path /org/gnome/Shell/Extensions \
         --method org.gnome.Shell.Extensions.InstallRemoteExtension \
         "$uuid" >/dev/null 2>&1
      return 0
   elif gnome-extensions list --updates | grep -qw "$uuid"; then
      echo "${GREEN}Sent update request for $uuid.${NC}"
      gdbus call --session --dest org.gnome.Shell.Extensions \
         --object-path /org/gnome/Shell/Extensions \
         --method org.gnome.Shell.Extensions.InstallRemoteExtension \
         "$uuid" >/dev/null 2>&1
      return 0
   else
      echo "${GREEN}GNOME Extension $uuid is already installed.${NC}"
      return 0
   fi
}

# Flags
reload=false
for arg in "$@"; do
   if [ "$arg" = "-r" ]; then
      reload=true
   fi
done

# Clone Dotfiles if not already present
cd "$HOME/dotfiles" || exit
if [ "$(pwd)" != "$HOME/dotfiles" ]; then
   echo "${YELLOW}Cloning dotfiles repository...${NC}"
   sudo apt update
   sudo apt install -y git
   if ! git clone https://github.com/TrudeEH/dotfiles --depth 1; then
      echo "${RED}Error cloning dotfiles repository. Exiting...${NC}"
      exit 2
   fi
   cd dotfiles || exit
   echo "${GREEN}dotfiles repository cloned successfully.${NC}"
else
   echo "${YELLOW}Updating dotfiles repository...${NC}"
   pull_output=$(git pull)
   echo "%s" "$pull_output"
   if ! echo "$pull_output" | grep -q "Already up to date."; then
      echo "${YELLOW}Changes detected. Re-running script...${NC}"
      exec "$0" "$@"
   fi
fi

mkdir -p "$HOME/dotfiles/logs"

echo "${CYAN}####################"
echo "#${PURPLE} Trude's Dotfiles${CYAN} #"
echo "####################"
fetch
echo

# Install Programs
if [ "$reload" = false ]; then
   sudo apt install curl git tmux fzf tealdeer pass-otp zbar-tools lynis bat ufw \
      gir1.2-gtop-2.0 lm-sensors # Vitals Extension deps
fi

# Copy files
echo "${YELLOW}Installing Dotfiles...${NC}"
cp -r "$HOME/dotfiles/home/." "$HOME"

# Copy scripts
echo "${YELLOW}Installing Scripts...${NC}"
mkdir -p "$HOME/.local/bin"
cp -r "$HOME/dotfiles/scripts/." "$HOME/.local/bin/"

# Install fonts
echo "${YELLOW}Installing fonts...${NC}"
mkdir -p "$HOME/.local/share/fonts"
cp -rf "$HOME/dotfiles/fonts/"* "$HOME/.local/share/fonts/"
fc-cache -fv "$HOME/.local/share/fonts" >"$HOME/dotfiles/logs/font_install.log"

# UFW Firewall
if [ "$reload" = false ]; then
   echo "${YELLOW}Setting up UFW...${NC}"
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   if systemctl is-active --quiet sshd; then
      echo "${YELLOW}SSH Server detected; Enabling SSH rule...${NC}"
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
      echo "${RED}ED25519 key not found in ${CYAN}$HOME/.ssh/id_ed25519. ${RED}Please add your ED25519 key pair for password-store.${NC}"
   elif ! gpg --list-keys "ehtrude@gmail.com" >/dev/null 2>&1; then
      echo "${RED}GPG key for ehtrude@gmail.com not found. Please import the key for password-store.${NC}"
   else
      if [ ! -d "$HOME/.password-store" ]; then
         echo "${YELLOW}Cloning password-store...${NC}"
         chmod 700 ~/.ssh
         chmod 600 ~/.ssh/*
         if ! git clone git@github.com:TrudeEH/password-store.git "$HOME/.password-store"; then
            echo "${RED}Error cloning password-store.${NC}"
         else
            echo "${GREEN}Password-store cloned successfully.${NC}"
         fi
      else
         echo "${CYAN}Password-store already present.${NC}"
      fi
   fi
fi

# Security Scan
if [ "$reload" = false ] && [ ! -f "$HOME/dotfiles/logs/lynis_scan.log" ]; then
   echo "${YELLOW}Running Lynis Security Scan...${NC}"
   if ! sudo lynis audit system | tee "$HOME/dotfiles/logs/lynis_scan.log"; then
      echo "${RED}Error running Lynis.${NC}"
   else
      echo "${GREEN}Lynis scan completed.${NC}"
   fi
else
   echo "${CYAN}Previous Lynis scan detected, read the log @ $HOME/dotfiles/logs/lynis_scan.log.${NC}"
fi

# Set up GNOME Desktop
case "$XDG_CURRENT_DESKTOP" in
*GNOME*)
   echo "${YELLOW}Installing GNOME Extensions...${NC}"
   install_gnome_extension "caffeine@patapon.info"
   install_gnome_extension "Vitals@CoreCoding.com"

   echo "${YELLOW}Loading Dconf settings...${NC}"
   if ! dconf load / <"$HOME/dotfiles/dconf-settings.ini"; then
      echo "${RED}Error loading Dconf settings.${NC}"
   fi
   ;;
esac
