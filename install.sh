#! /bin/bash

if ! command -v dialog; then
  sudo apt-get install dialog -y
fi

# Set dialog colors
cp -f dotfiles/.dialogrc  $HOME/.dialogrc

BACKTITLE="Trude's FreeBSD Toolkit"
dialog --erase-on-exit \
       --backtitle "$BACKTITLE" \
       --checklist "Use the arrow keys and SPACE to select, then press ENTER." 30 90 5 \
        "1" "Update Debian" "on"\
        "2" "Install Dotfiles" "on"\
        "3" "Install GitHub CLI" "off"\
        "4" "Install AI Tools" "off"\
        "5" "Install MultiMC" "off" 2> main.tmp
main_menu=$( cat main.tmp )
rm main.tmp
mkdir logs

rm logs/compile.log
rm logs/compile.err.log
compile() {
  cd $HOME/dotfiles/programs/$1
  sudo rm -rf config.h
  sudo make clean install >> $HOME/dotfiles/logs/compile.log 2>> $HOME/dotfiles/logs/compile.err.log
  cd $HOME/dotfiles
}

for selection in $main_menu; do
  if [ "$selection" = "1" ]; then
    # --- UPDATE DEBIAN ---

    dialogUpdate() {
      dialog --backtitle "$BACKTITLE" --title "Update Debian and Packages" \
	       --mixedgauge "Updating..." \
	       0 0 $1 \
         "Update repos" "$2" \
         "Update distro" "$3" \
         "Update packages" "$4" \
         "Clean up " "$5"
    }

    dialogUpdate 0 7 4 4 4

    sudo apt-get update > logs/update.log
    dialogUpdate 15 5 7 4 4

    sudo apt-get dist-upgrade -y >> logs/update.log
    dialogUpdate 35 5 5 7 4

    sudo apt-get upgrade -y >> logs/update.log
    dialogUpdate 80 5 5 5 7

    sudo apt-get clean
    sudo apt-get autoremove -y >> logs/update.log
    dialogUpdate 100 5 5 5 5
  fi

  if [ "$selection" = "3" ]; then
    # --- INSTALL GH CLI ---

    {
      sudo apt-get update
      sudo apt-get install wget -y
      sudo mkdir -p -m 755 /etc/apt/keyrings
      sudo rm -f /etc/apt/sources.list.d/github-cli.list 2>/dev/null
      wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
      sudo apt-get update
      sudo apt-get install gh -y
    } | dialog --backtitle "$BACKTITLE" --programbox "Install GitHub CLI" 30 90
  fi

  if [ "$selection" = "4" ]; then
    # --- Install AI Tools ---

    clear
    echo "------------------------"
    echo "--- Install AI Tools ---"
    echo "------------------------"
    echo
    echo

    # Ollama - LLM Server
    curl -fsSL https://ollama.com/install.sh | sh

    # Fabric - LLM Client w/ prompts
    cd $HOME
    git clone https://github.com/danielmiessler/fabric.git
    sudo apt-get install pipx ffmpeg
    cd fabric
    pipx install .
    fabric --setup
    cd ..
    rm -rf fabric
  fi

  if [ "$selection" = "5" ]; then
    # --- Install MultiMC ---

    {
      sudo apt-get update
      sudo apt-get install -y libqt5core5a libqt5network5 libqt5gui5
      wget https://files.multimc.org/downloads/multimc_1.6-1.deb 2> /dev/null
      sudo apt-get install -y ./multimc_1.6-1.deb
      rm multimc_1.6-1.deb

      # Install java
      sudo mkdir -p /etc/apt/keyrings 2> /dev/null
      wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc > /dev/null 2>&1
      echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list > /dev/null 2>&1
      sudo apt-get update
      sudo apt-get install -y temurin-8-jdk temurin-21-jdk temurin-17-jdk
    } | dialog --backtitle "$BACKTITLE" --programbox "Install Minecraft (MultiMC)" 30 90
  fi

  if [ "$selection" = "2" ]; then
    # --- INSTALL DOTFILES ---

    dialogDotfiles() {
      dialog --backtitle "$BACKTITLE" --title "Install Trude's Dotfiles" \
        --mixedgauge "Installing dotfiles..." \
        0 0 $1 \
        "Install Xorg" "$2" \
        "Install Desktop Dependencies" "$3" \
        "Install Audio Server" "$4" \
        "Install Network Daemon" "$5" \
        "Install Firefox" "$6" \
        "Install Utilities" "$7" \
        "Compile Programs" "$8" \
        "Copy Dotfiles to \$HOME" "$9"
    }

    dialogDotfiles 0 7 4 4 4 4 4 4 4
    # Xorg
    sudo apt-get install xorg -y > logs/dotfiles.log
    dialogDotfiles 20 5 7 4 4 4 4 4 4

    # DE Deps
    sudo apt-get install libx11-dev libxft-dev libxinerama-dev build-essential libxrandr-dev -y >> logs/dotfiles.log
    dialogDotfiles 30 5 5 7 4 4 4 4 4

    # Audio
    sudo apt-get install pipewire-audio wireplumber pipewire-pulse pipewire-alsa -y >> logs/dotfiles.log
    systemctl --user --now enable wireplumber.service >> logs/dotfiles.log
    dialogDotfiles 45 5 5 5 7 4 4 4 4

    # Network
    sudo apt-get install iwd systemd-resolved -y >> logs/dotfiles.log
    sudo systemctl enable iwd systemd-resolved >> logs/dotfiles.log 2> logs/dotfiles.iwd.log
    dialogDotfiles 60 5 5 5 5 7 4 4 4

    # Firefox
    sudo apt-get install firefox-esr -y >> logs/dotfiles.log
    dialogDotfiles 75 5 5 5 5 5 7 4 4

    # Utilities
    sudo apt-get install htop fzf tmux git vim wget curl feh scrot dunst -y >> logs/dotfiles.log
    dialogDotfiles 85 5 5 5 5 5 5 7 4

    # Compile
    for program in "dwm" "dmenu" "slock" "slstatus" "st" "tabbed" "surf"; do
      compile $program
    done
    dialogDotfiles 95 5 5 5 5 5 5 5 7

    # Copy configs | end
    cp -vrf dotfiles/.* $HOME >> logs/dotfiles.log
    fc-cache -f
    # Copy wifi config
    sudo cp -f iwd.conf /etc/iwd/main.conf
    dialogDotfiles 100 5 5 5 5 5 5 5 5
  fi
done

clear
