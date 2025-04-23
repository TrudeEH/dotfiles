#! /bin/sh

# Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

trap 'printf "${RED}debian.sh interrupted.${NC}"; exit 1' INT TERM

echo "Debian Sources:"
echo "1) Stable"
echo "2) Testing"
printf "Enter your choice: "

while read -r REPLY; do
  case $REPLY in
  1)
    echo "${CYAN}Using Stable sources.${NC}"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bckp
    sudo cp stable-sources.list /etc/apt/sources.list
    break
    ;;
  2)
    echo "${CYAN}Using Testing sources.${NC}"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bckp
    sudo cp testing-sources.list /etc/apt/sources.list
    break
    ;;
  *)
    echo "Invalid option."
    printf "Enter your choice: "
    ;;
  esac
done

./scripts/update

echo "${YELLOW}Installing GNOME...${NC}"
sudo apt install gnome-core flatpak gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Enable Network Manager
echo "${YELLOW}Enabling Network Manager...${NC}"
sudo mv /etc/network/interfaces /etc/network/interfaces.bckp
sudo systemctl restart networking
sudo service NetworkManager restart

# Remove Firefox (Epiphany installed instead)
echo "${YELLOW}Removing Firefox...${NC}"
sudo apt purge firefox-esr
