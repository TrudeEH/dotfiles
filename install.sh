#! /bin/sh

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BOLD="\e[1m"
NC="\e[0m"

install_gnome_extension() {
   uuid="$1"

   if [ -z "$uuid" ]; then
      printf "%b\n" "${RED}Usage: install_gnome_extension <extension-uuid>${NC}"
      return 1
   fi

   if ! gnome-extensions list | grep -qw "$uuid"; then
      printf "%b\n" "${YELLOW}[+]${NC} Sent install request for $uuid."
      gdbus call --session --dest org.gnome.Shell.Extensions \
         --object-path /org/gnome/Shell/Extensions \
         --method org.gnome.Shell.Extensions.InstallRemoteExtension \
         "$uuid" >/dev/null 2>&1
      return 0
   elif gnome-extensions list --updates | grep -qw "$uuid"; then
      printf "%b\n" "${YELLOW}[+]${NC} Sent update request for $uuid."
      gdbus call --session --dest org.gnome.Shell.Extensions \
         --object-path /org/gnome/Shell/Extensions \
         --method org.gnome.Shell.Extensions.InstallRemoteExtension \
         "$uuid" >/dev/null 2>&1
      return 0
   else
      printf "%b\n" "${GREEN}[✓]${NC} GNOME Extension $uuid is already installed."
      return 0
   fi
}

trap 'printf "${RED}install.sh interrupted.${NC}"; exit 1' INT TERM

if ! command -v whiptail >/dev/null 2>&1; then
   printf "%b\n" "${YELLOW}[+]${NC} Installing whiptail..."
   sudo pacman -Sy whiptail
fi

case "$XDG_CURRENT_DESKTOP" in
*GNOME*)
   printf "%b\n" "${GREEN}[✓]${NC} Running on GNOME."
   ;;
*)
   whiptail --title "Warning" --msgbox \
      "Dconf settings and GNOME extensions can only be installed from within GNOME.\n\nPlease run this script again from within a GNOME session." \
      15 60
   ;;
esac

window_height='15'
window_width='60'

W_MAIN=$(
   whiptail --notags --title "Trude's Dotfiles" \
      --cancel-button "Exit" \
      --menu "Main Menu" $window_height $window_width 6 \
      "install" "Install Dotfiles" \
      "reload" "Reload Configuration" \
      "paru" "Install Paru AUR Helper" \
      "flatpak" "Install Flatpak" \
      "update" "Update Distro" \
      "vulns" "Check for Vulnerabilities" \
      3>&1 1>&2 2>&3
)

if [ -z $W_MAIN ]; then
   exit 1
fi

if [ $W_MAIN = "update" ]; then
   ./scripts/update
   exit 0
fi

# Clone Dotfiles if not already present
cd "$HOME/dotfiles"
if [ "$(pwd)" != "$HOME/dotfiles" ]; then
   printf "%b\n" "${YELLOW}[+]${NC} Cloning dotfiles repository..."
   sudo pacman -Sy git
   if ! git clone https://git.trude.dev/trude/dotfiles --depth 1; then
      printf "%b\n" "${RED}Error cloning dotfiles repository. Update skipped...${NC}"
   fi
   cd dotfiles || exit
   printf "%b\n" "${GREEN}[✓]${NC} Dotfiles repository cloned successfully."
else
   printf "%b\n" "${YELLOW}[+]${NC} Updating dotfiles repository..."
   pull_output=$(git pull)
   echo "$pull_output"
   if ! echo "$pull_output" | grep -q "Already up to date."; then
      printf "%b\n" "${YELLOW}Changes detected. Please re-run the script. Ignore this warning if you don't have an internet connection.${NC}"
   fi
fi

mkdir -p "$HOME/dotfiles/logs"

if [ $W_MAIN = "flatpak" ]; then
   sudo pacman -Sy flatpak
   sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if [ $W_MAIN = "vulns" ]; then
   arch-audit
fi

if [ $W_MAIN = "paru" ]; then
   sudo pacman -S --needed base-devel
   git clone https://aur.archlinux.org/paru.git --depth=1
   cd paru
   makepkg -si
   cd ..
   rm -rf paru
fi

if [ $W_MAIN = "install" ]; then
   sudo cp -f ./pacman.conf /etc/pacman.conf
   ./scripts/update

   printf "%b\n" "${YELLOW}[+]${NC} Installing Dependencies..."
   sudo pacman -Sy --needed git tmux fzf tealdeer pass-otp bat ufw unp bash-completion gnome-keyring libsecret pacman-contrib reflector arch-audit

   # Enable GNOME Keyring SSH agent
   printf "%b\n" "${YELLOW}[+]${NC} Enabling GNOME Keyring SSH agent..."
   systemctl enable --user gcr-ssh-agent.socket
   systemctl start --user gcr-ssh-agent.socket

   printf "%b\n" "${YELLOW}[+]${NC} Selecting Fastest Arch Mirrors..."
   sudo reflector --sort rate --fastest 10 --verbose --protocol https --latest 200 --save /etc/pacman.d/mirrorlist
fi

if [ "$W_MAIN" = "install" ] || [ "$W_MAIN" = "reload" ]; then
   # Copy files
   printf "%b\n" "${YELLOW}[+]${NC} Installing Dotfiles..."
   cp -r "$HOME/dotfiles/home/." "$HOME"

   # Copy wallpapers
   printf "%b\n" "${YELLOW}[+]${NC} Installing Wallpapers..."
   sudo cp -r $HOME/dotfiles/wallpapers/* /usr/share/backgrounds/gnome/

   # Copy scripts
   printf "%b\n" "${YELLOW}[+]${NC} Installing Scripts..."
   mkdir -p "$HOME/.local/bin"
   cp -r "$HOME/dotfiles/scripts/." "$HOME/.local/bin/"

   # Install fonts
   printf "%b\n" "${YELLOW}[+]${NC} Installing fonts..."
   mkdir -p "$HOME/.local/share/fonts"
   cp -rf "$HOME/dotfiles/fonts/"* "$HOME/.local/share/fonts/"
   if [ ! -f "$HOME/dotfiles/logs/font_install.log" ]; then
      fc-cache -fv "$HOME/.local/share/fonts" >"$HOME/dotfiles/logs/font_install.log"
   fi

   # UFW Firewall
   if [ "$reload" = false ]; then
      printf "%b\n" "${YELLOW}[+]${NC} Setting up UFW..."
      sudo ufw default deny incoming
      sudo ufw default allow outgoing
      if systemctl is-active --quiet sshd; then
         printf "%b\n" "${YELLOW}[+]${NC} SSH Server detected; Enabling SSH rule..."
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
         printf "%b\n" "${RED}ED25519 key not found in ${CYAN}$HOME/.ssh/id_ed25519. ${RED}Please add your ED25519 key pair for password-store.${NC}"
      elif ! gpg --list-keys "ehtrude@gmail.com" >/dev/null 2>&1; then
         printf "%b\n" "${RED}GPG key for ehtrude@gmail.com not found. Please import the key for password-store.${NC}"
      else
         if [ ! -d "$HOME/.password-store" ]; then
            printf "%b\n" "${YELLOW}[+]${NC} Cloning password-store..."
            chmod 700 ~/.ssh
            chmod 600 ~/.ssh/*
            if ! git clone git@git.trude.dev:trude/password-store.git "$HOME/.password-store"; then
               printf "%b\n" "${RED}Error cloning password-store.${NC}"
            else
               printf "%b\n" "${GREEN}[✓]${NC} Password-store cloned successfully."
            fi
         else
            printf "%b\n" "${GREEN}[✓]${NC} Password-store already present."
         fi
      fi
   fi

   # Set up GNOME Desktop
   case "$XDG_CURRENT_DESKTOP" in
   *GNOME*)
      printf "%b\n" "${YELLOW}[+]${NC} Installing GNOME Extensions..."
      install_gnome_extension "caffeine@patapon.info"
      install_gnome_extension "Vitals@CoreCoding.com"
      install_gnome_extension "appindicatorsupport@rgcjonas.gmail.com"
      install_gnome_extension "gsconnect@andyholmes.github.io"

      printf "%b\n" "${YELLOW}[+]${NC} Loading Dconf settings..."
      if ! dconf load / <"$HOME/dotfiles/dconf-settings.ini"; then
         printf "%b\n" "${RED}Error loading Dconf settings.${NC}"
      fi
      ;;
   *)
      printf "\n\n"
      printf "%b\n" "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
      printf "\n"
      printf "%b\n" "${CYAN}Dconf settings and GNOME extensions can only be installed after restarting."
      printf "%b\n" "${CYAN}Please run the script again from within GNOME (with the reload option).${NC}"
      printf "\n"
      printf "%b\n" "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
      printf "\n"
      ;;
   esac
fi