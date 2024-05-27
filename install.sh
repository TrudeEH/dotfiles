#! /bin/bash

source scripts/TUI.bash
# export LOG_LEVEL="$LOG_DEBUG"

echo "Updating Debian..."
sudo apt install nala -y
sudo nala update
sudo nala upgrade
echo
echo "##########################"
echo "# Trude's Debian Toolkit #"
echo "##########################"
if [ $? == 0 ]; then
  show_success "System updated."
else
  show_error "Update failed."
  exit 1
fi
echo

main_menu_opts=("Install Trude's Dotfiles" "Install GNOME (desktop)" "Install GitHub CLI" "Install Google Chrome" "Install Ollama" "Install VSCode" "Install Tailscale" "+Install Games")
main_menu=$(checkbox "Press SPACE to select and ENTER to continue." "${main_menu_opts[@]}")

log "$LOG_DEBUG" "Menu opts: $main_menu"

# Submenus
if [[ ${main_menu[@]} =~ 7 ]]; then # +Games
  echo "Select games to install"
  game_menu_opts=("Install MultiMC and Java 8,17,21." "Install Minecraft Bedrock" "Install Steam")
  game_menu=$(checkbox "Press SPACE to select and ENTER to continue." "${game_menu_opts[@]}")

  if [[ ${game_menu[@]} =~ 0 ]]; then # Install MultiMC
    # Install multimc
    sudo nala update
    sudo nala install libqt5core5a libqt5network5 libqt5gui5
    wget https://files.multimc.org/downloads/multimc_1.6-1.deb
    sudo nala install ./multimc_1.6-1.deb
    rm multimc_1.6-1.deb

    # Install java
    sudo mkdir -p /etc/apt/keyrings
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
    sudo nala update
    sudo nala install temurin-8-jdk temurin-21-jdk temurin-17-jdk
  fi

  if [[ ${game_menu[@]} =~ 1 ]]; then # Install Minecraft Bedrock
    curl -sS https://minecraft-linux.github.io/pkg/deb/pubkey.gpg | sudo tee -a /etc/apt/trusted.gpg.d/minecraft-linux-pkg.asc
    echo "deb [arch=amd64,arm64,armhf] https://minecraft-linux.github.io/pkg/deb bookworm-nightly main" | sudo tee /etc/apt/sources.list.d/minecraft-linux-pkg.list
    sudo nala update
    sudo nala install mcpelauncher-manifest mcpelauncher-ui-manifest msa-manifest
  fi

  if [[ ${game_menu[@]} =~ 2 ]]; then # Install Steam
    echo "Add \"contrib non-free\" to the end of each repo. Press ENTER to edit /etc/apt/sources.list."
    read
    sudoedit /etc/apt/sources.list

    sudo dpkg --add-architecture i386
    sudo nala update
    sudo nala install mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
    sudo nala install steam
  fi

fi

# Main menu items
if [[ ${main_menu[@]} =~ 0 ]]; then # Install Dotfiles
  sudo nala install htop fzf tmux git stow vim wget

  # Clone repo if needed
  if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles --depth=1
    cd dotfiles
  fi

  # Link dotfiles
  stow -v -t $HOME dotfiles --adopt
  git diff
  git reset --hard

  # Reload Fonts
  fc-cache -fv
fi

if [[ ${main_menu[@]} =~ 1 ]]; then # GNOME
  sudo nala install gnome-core
  sudo rm -rf /etc/network/interfaces #Fix Wifi settings bug
  dconf load / <./settings.dconf
fi

if [[ ${main_menu[@]} =~ 2 ]]; then # Github CLI
  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) &&
    sudo mkdir -p -m 755 /etc/apt/keyrings &&
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo nala update &&
    sudo nala install gh -y
  if [ $? == 0 ]; then
    show_success "GitHub CLI Installed."
  else
    show_error "Failed to install Github CLI."
  fi
fi

if [[ ${main_menu[@]} =~ 3 ]]; then # Chrome
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo nala install ./google-chrome-stable_current_amd64.deb
  rm ./google-chrome-stable_current_amd64.deb
fi

if [[ ${main_menu[@]} =~ 4 ]]; then # Ollama
  curl -fsSL https://ollama.com/install.sh | sh
fi

if [[ ${main_menu[@]} =~ 5 ]]; then # VSCode
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/microsoft-archive-keyring.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo rm microsoft.gpg
  sudo nala update
  sudo nala install code
fi

if [[ ${main_menu[@]} =~ 6 ]]; then # Tailscale
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo systemctl enable tailscaled
  sudo tailscale up
fi
