#!/bin/bash

# Parse flags
help_message="Usage: $0 [--desktop|-d | --hyprland|-h | --terminal|-t]

Options:
  --desktop,  -d  Install desktop programs and configure GNOME (must already be installed).
  --hyprland, -h  Install desktop programs and Hyprland.
  --terminal, -t  Only install the basic dependencies for CLI use."

if [ $# -eq 0 ]; then
   echo "$help_message"
   exit 1
fi

while [[ $# -gt 0 ]]; do
   case "$1" in
   --desktop | -d)
      desktop=true
      hyprland=false
      shift
      ;;
   --hyprland | -h)
      desktop=true
      hyprland=true
      shift
      ;;
   --terminal | -t)
      desktop=false
      hyprland=false
      shift
      ;;
   *)
      echo "Unknown option: $1"
      echo "$help_message"
      exit 1
      ;;
   esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "####################"
echo -n "#"
echo -e "${PURPLE} Trude's Dotfiles${CYAN} #"
echo "####################"
echo -e "${CYAN}Running on: ${PURPLE}$OSTYPE${NC}"
echo

# Detect package managers and update repositories
if [[ "$OSTYPE" == "darwin"* ]]; then
   if ! command -v brew >/dev/null 2>&1; then
      echo -e "${YELLOW}[+] Installing Homebrew...${NC}"
      chsh -s /bin/bash # Switch to bash (optional)
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   fi
   pkg_manager="brew"
   echo -e "${YELLOW}[+] Updating Homebrew repositories...${NC}"
   brew update
elif command -v apt >/dev/null 2>&1; then
   pkg_manager="apt"
   echo -e "${YELLOW}[+] Updating APT repositories...${NC}"
   sudo apt update
elif command -v dnf >/dev/null 2>&1; then
   pkg_manager="dnf"
   echo -e "${YELLOW}[+] Updating DNF repositories...${NC}"
   sudo dnf update
elif command -v pacman >/dev/null 2>&1; then
   pkg_manager="pacman"
   echo -e "${YELLOW}[+] Updating PACMAN repositories...${NC}"
   sudo pacman -Sy
else
   echo -e "${RED}[E] No supported package manager found. Exiting...${NC}"
   exit 1
fi

# Install Programs
programs=(neovim curl git tmux bmon fzf gcc make gpg)

if $desktop; then
   programs+=(
      tldr    # Simplified man pages
      weechat # IRC client
      #w3m         # Text-based web browser
      #nnn         # File manager
      #taskwarrior # Task manager
      #mutt        # Email client
      #pass-otp   # Password manager
      #zbar-tools # QR code reader
   )
fi

if $hyprland; then
   programs+=(
      dunst                       # Notifications
      foot                        # Terminal
      hyprland                    # Window manager
      hyprlock                    # Screen locker
      hyprpaper                   # Wallpaper manager
      hyprpicker                  # Color picker
      hyprpolkitagent             # Auth pop-up for sudo access
      network-manager             # Network manager
      pipewire                    # Audio server
      udiskie                     # Automount USB drives
      waybar                      # Status bar
      wireplumber                 # PipeWire session manager
      wofi                        # Launcher
      xdg-desktop-portal-hyprland # D-Bus support for Hyprland

      nautilus # File manager

      qt5-wayland # Qt5 Wayland support
      qt6-wayland # Qt6 Wayland support
   )
fi

for prog in "${programs[@]}"; do
   echo -e "${YELLOW}[+] Installing ${prog}...${NC}"
   case $pkg_manager in
   brew)
      brew install "$prog"
      ;;
   apt)
      sudo apt install -y "$prog"
      ;;
   dnf)
      sudo dnf install -y "$prog"
      ;;
   pacman)
      sudo pacman -S --needed --noconfirm "$prog"
      ;;
   esac
   if [ $? -ne 0 ]; then
      echo -e "${RED}[E] Error installing ${prog}.${NC}"
   else
      echo -e "${GREEN}[I] ${prog} installed successfully.${NC}"
   fi
done

# Clone Dotfiles if not already present
cd $HOME/dotfiles
if [ $(pwd) != "$HOME/dotfiles" ]; then
   echo -e "${YELLOW}[+] Cloning dotfiles repository...${NC}"
   git clone https://github.com/TrudeEH/dotfiles --depth 1
   if [ $? -ne 0 ]; then
      echo -e "${RED}[E] Error cloning dotfiles repository. Exiting...${NC}"
      exit 2
   fi
   cd dotfiles
   echo -e "${GREEN}[I] dotfiles repository cloned successfully.${NC}"
else
   echo -e "${GREEN}[I] dotfiles repository already present.${NC}"
fi

# Copy files
echo -e "${YELLOW}[+] Installing Dotfiles...${NC}"
cp -r $HOME/dotfiles/home/. $HOME
if [ $? -ne 0 ]; then
   echo -e "${RED}[E] Error copying Dotfiles.${NC}"
else
   echo -e "${GREEN}[I] Dotfiles installed successfully.${NC}"
fi

# Copy scripts
echo -e "${YELLOW}[+] Installing Scripts...${NC}"
mkdir -p $HOME/.local/bin
cp -r $HOME/dotfiles/scripts/. $HOME/.local/bin/
if [ $? -ne 0 ]; then
   echo -e "${RED}[E] Error copying Scripts.${NC}"
else
   echo -e "${GREEN}[I] Scripts installed successfully.${NC}"
fi

# Install fonts
echo -e "${YELLOW}[+] Installing fonts...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
   cp -rf $HOME/dotfiles/fonts/* $HOME/Library/Fonts/
   if [ $? -ne 0 ]; then
      echo -e "${RED}[E] Error installing fonts.${NC}"
   else
      echo -e "${GREEN}[I] Fonts installed successfully.${NC}"
   fi
else
   mkdir -p $HOME/.local/share/fonts
   cp -rf $HOME/dotfiles/fonts/* $HOME/.local/share/fonts/
   if [ $? -ne 0 ]; then
      echo -e "${RED}[E] Error installing fonts.${NC}"
   else
      fc-cache -fv $HOME/.local/share/fonts
      echo -e "${GREEN}[I] Fonts installed successfully.${NC}"
   fi
fi

# Load Dconf (GNOME settings)
if $desktop; then
   if [[ "$OSTYPE" != "darwin"* ]]; then
      echo -e "${YELLOW}[+] Loading Dconf settings...${NC}"
      dconf load / <$HOME/dotfiles/dconf-settings.ini
      if [ $? -ne 0 ]; then
         echo -e "${RED}[E] Error loading Dconf settings.${NC}"
      else
         echo -e "${GREEN}[I] Dconf settings loaded successfully.${NC}"
      fi
   fi
fi
