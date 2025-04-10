#! /bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

trap "echo -e '${RED}debian.sh interrupted.${NC}'; exit 1" SIGINT SIGTERM

PS3="Debian Sources: "
options=("Stable" "Testing")

select opt in "${options[@]}"; do
  case $REPLY in
  1)
    echo -e "${CYAN}Using Stable sources.${NC}"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bckp
    sudo cp stable-sources.list /etc/apt/sources.list
    break
    ;;
  2)
    echo -e "${CYAN}Using Testing sources.${NC}"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bckp
    sudo cp testing-sources.list /etc/apt/sources.list
    break
    ;;
  *)
    echo "Invalid option."
    ;;
  esac
done

./scripts/update

echo -e "${YELLOW}Installing GNOME...${NC}"
sudo apt install gnome-core flatpak gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Enable Network Manager
echo -e "${YELLOW}Enabling Network Manager...${NC}"
sudo mv /etc/network/interfaces /etc/network/interfaces.bckp
sudo systemctl restart networking
sudo service NetworkManager restart

# Remove Firefox (Epiphany installed instead)
echo -e "${YELLOW}Removing Firefox...${NC}"
sudo apt purge firefox-esr
