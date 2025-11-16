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
   sudo pacman -S libnewt
fi

window_height='15'
window_width='60'

W_MAIN=$(
   whiptail --notags --title "Trude's Dotfiles" \
      --cancel-button "Exit" \
      --menu "Main Menu" $window_height $window_width 8 \
      "setup" "Install GNOME & Core Apps" \
      "install" "Install Dotfiles" \
      "" "" \
      "reload" "Reload Configuration" \
      "paru" "Install Paru AUR Helper" \
      "flatpak" "Install Flatpak" \
      "update" "Update Distro" \
      "vulns" "Check for Vulnerabilities" \
      3>&1 1>&2 2>&3
)

if [ -z "$W_MAIN" ]; then
   exit 1
fi

if [ "$W_MAIN" = "update" ]; then
   ./scripts/update
   exit 0
fi

# Clone Dotfiles if not already present
cd "$HOME/dotfiles"
if [ "$(pwd)" != "$HOME/dotfiles" ]; then
   printf "%b\n" "${YELLOW}[+]${NC} Cloning dotfiles repository..."
   sudo pacman -S git
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

if [ "$W_MAIN" = "flatpak" ]; then
   sudo pacman -S flatpak
   sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if [ "$W_MAIN" = "vulns" ]; then
   printf "%b\n" "${CYAN}[I]${NC} Packages that contain known vulnerabilities:"
   arch-audit
   printf "\n%b\n" "${RED}[I]${NC} Packages that can be fixed by updating:"
   arch-audit -u
fi

if [ "$W_MAIN" = "paru" ]; then
   sudo pacman -S --needed base-devel
   git clone https://aur.archlinux.org/paru.git --depth=1
   cd paru
   makepkg -si
   cd ..
   rm -rf paru
fi

if [ "$W_MAIN" = "setup" ]; then
   printf "%b\n" "${YELLOW}[+]${NC} Installing GNOME..."
   sudo pacman -S gnome

   printf "%b\n" "${YELLOW}[+]${NC} Installing GNOME Circle Apps..."
   sudo pacman -S --needed amberol apostrophe audio-sharing blanket collision curtail decoder dialect eartag errands eyedropper fragments gnome-podcasts graphs health hieroglyphic identity impression iotas komikku letterpress mousai newsflash obfuscate paper-clip pika-backup raider resources secrets shortwave solanum switcheroo valuta video-trimmer warp wike 

   if whiptail --title "Developer Tools" --yesno "Are you a developer?\n\nInstall GNOME development tools?" 10 64; then
      printf "%b\n" "${YELLOW}[+]${NC} Installing GNOME development tools..."
      sudo pacman -S --needed manuals binary commit emblem gnome-builder lorem textpieces webfont-kit-generator sysprof gnome-boxes d-spy dconf-editor
      printf "%b\n" "${CYAN}[I]${NC} Install workbench through the AUR for more convenient prototyping."
   else
      printf "%b\n" "${CYAN}[+]${NC} Skipped installing development tools."
   fi

   printf "%b\n" "${YELLOW}[+]${NC} Enabling GDM..."
   sudo systemctl enable gdm.service
fi

if [ "$W_MAIN" = "install" ]; then
   sudo cp -f ./pacman.conf /etc/pacman.conf
   ./scripts/update

   printf "%b\n" "${YELLOW}[+]${NC} Installing Dependencies..."
   sudo pacman -S --needed git fzf tealdeer bat ufw unp bash-completion gnome-keyring libsecret pacman-contrib reflector arch-audit

   # Enable GNOME Keyring SSH agent
   printf "%b\n" "${YELLOW}[+]${NC} Enabling GNOME Keyring SSH agent..."
   systemctl enable --user gcr-ssh-agent.socket
   systemctl start --user gcr-ssh-agent.socket

   printf "%b\n" "${YELLOW}[+]${NC} Selecting Fastest Arch Mirrors..."
   sudo reflector --sort rate --fastest 10 --verbose --protocol https --latest 200 --save /etc/pacman.d/mirrorlist
fi

if [ ""$W_MAIN"" = "install" ] || [ ""$W_MAIN"" = "reload" ]; then
   # Copy files
   printf "%b\n" "${YELLOW}[+]${NC} Installing Dotfiles..."
   cp -r "$HOME/dotfiles/home/." "$HOME"

   # Copy wallpapers
   printf "%b\n" "${YELLOW}[+]${NC} Installing Wallpapers..."
   sudo mkdir -p /usr/share/backgrounds/gnome/
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
      git config --global core.editor "/usr/bin/re.sonny.Commit"

      # Configure SSH
      if [ ! -f "$HOME/.ssh/id_ed25519" ] || [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
         printf "%b\n" "${RED}ED25519 key not found in ${CYAN}$HOME/.ssh/id_ed25519${NC}."
      else
         chmod 700 ~/.ssh
         chmod 600 ~/.ssh/*
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
      install_gnome_extension "blur-my-shell@aunetx"

      printf "%b\n" "${YELLOW}[+]${NC} Loading Dconf settings..."
      if ! dconf load / <"$HOME/dotfiles/dconf-settings.ini"; then
         printf "%b\n" "${RED}Error loading Dconf settings.${NC}"
      fi
      ;;
   *)
      whiptail --title "Warning" --msgbox \
         "Dconf settings and GNOME extensions can only be installed from within GNOME.\n\nPlease run this script again from within a GNOME session." \
         15 60
      ;;
   esac
fi