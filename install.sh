#! /bin/bash

source scripts/bash-tui-toolkit.bash
export LOG_LEVEL="$LOG_DEBUG"

echo "Updating Debian..."
sudo apt install nala -y
sudo nala update
sudo nala upgrade
echo
echo "------------------------------"
echo "--- Trude's Debian Toolkit ---"
echo "------------------------------"
if [ $? == 0 ]; then
  show_success "System updated."
else
  show_error "Update failed."
  exit 1
fi
echo
main_menu_opts=("Install Trude's Dotfiles" "Install GNOME (desktop)" "Install GitHub CLI" "Install Google Chrome")
main_menu=$(checkbox "Press SPACE to select and ENTER to continue." "${main_menu_opts[@]}")

log "$LOG_DEBUG" "Menu opts: $main_menu"

if [[ ${main_menu[@]} =~ 0 ]]; then # Install Dotfiles
  sudo nala install htop fzf tmux git stow vim wget

  # Clone repo if needed
  if [ $(pwd) != "$HOME/cros" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles --depth=1
    cd cros
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
  dconf load / < ./settings.dconf
fi

if [[ ${main_menu[@]} =~ 2 ]]; then # Github CLI
  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo nala update \
  && sudo nala install gh -y
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

